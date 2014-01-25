require 'mongo'
require 'hashids'

include Mongo
include BSON

# TODO edge cases: nil values / errors 
# TODO connection pool (share connection across requests)
# TODO multi-tanency design (same db for all users?)
# TODO LIST API limit count?
# TODO API failure 503? 500?
# TODO Complete the interface according to Parse

# === About ObjectId ===
#
# There are really 2 ways to truly gaurantee unique IDs
# 1) increment id by 1 each time
# 2) have a set of IDs stored somewhere and take them one by one
#
# Neither works too well if I have to generate the id on the app side
#
# So eventually I'm leaving mongodb to generate the id and I put a
# reversible hash function on top of it to make shorter and more random
# user-facing ids.
#
# This is actually good performance-wise too. Now we are not wasting
# the underlying primary index and do not have to create a separate
# index to track uniqueness of our own ids.
# 
class ClassesController < ApplicationController
  
  # don't want csrf protection
  skip_before_action :verify_authenticity_token

  # constants
  MONGO_ID_KEY = '_id' 
  OBJECT_ID_KEY = 'objectId'
  CREATION_TIME_KEY = 'createdAt'
  UPDATE_TIME_KEY = 'updatedAt'
  RESULTS_KEY = 'results'

  OBJECT_ID_BYTE_LEN = 5

  MY_SALT = 'It really does not matter if you know this'

  def initialize
    @mongo = MongoClient.new('50.17.233.96', 27017)
    @db = @mongo['test']
    @hashids = Hashids.new(MY_SALT)
  end

  public

  # List all objects under class
  def index
    coll = @db[params[:className]]

    objs =  coll.find().to_a.each do |obj|
              mongoId = obj[MONGO_ID_KEY]
              obj.delete(MONGO_ID_KEY) 
              obj[OBJECT_ID_KEY] = mongo_to_object_id(mongoId)
            end

    ret = Hash.new
    ret[RESULTS_KEY] = objs

    render json: ret
  end

  # Create a new object
  #
  # object id and creation time are automattically added
  #
  def create
    coll = @db[params[:className]]

    # construct the object. objectId is not needed
    obj = JSON.parse(request.body.read)
    obj[CREATION_TIME_KEY] = Time.now.utc

    mongoId = coll.insert(obj)

    ret = Hash.new
    ret[OBJECT_ID_KEY] = mongo_to_object_id(mongoId)
    ret[CREATION_TIME_KEY] = obj[CREATION_TIME_KEY]

    render json: ret, status: 201
  end

  # Retrieve the object 
  def show
    # get the data
    coll = @db[params[:className]]
    mongoId = object_to_mongo_id(params[:id])
    obj = coll.find_one(MONGO_ID_KEY => mongoId)
    
    # hide mongoid
    obj.delete(MONGO_ID_KEY)
    obj[OBJECT_ID_KEY] = params[:id]
    render json: obj 
  end

  # Update the object
  def update
    coll = @db[params[:className]]

    obj = JSON.parse(request.body.read)
    obj[UPDATE_TIME_KEY] = Time.now.utc
    coll.update({MONGO_ID_KEY => object_to_mongo_id(params[:id])}, 
                 {'$set' => obj})

    ret = Hash.new
    ret[UPDATE_TIME_KEY] = obj[UPDATE_TIME_KEY]
    render json: ret
  end

  # Remove the object
  def destroy
    coll = @db[params[:className]]
    coll.remove(MONGO_ID_KEY => object_to_mongo_id(params[:id]))
    render nothing: true
  end

  private

  #
  def mongo_to_object_id mongoId
    @hashids.encrypt_hex(mongoId.to_s)         
  end

  #
  def object_to_mongo_id objectId
    ObjectId.from_string(@hashids.decrypt_hex(objectId).to_str)
  end

end
