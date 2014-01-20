require 'mongo'
require 'securerandom'

include Mongo
include BSON

# TODO uuid generation (currently no uniqueness gaurantee)
# TODO edge cases: nil values / errors 
# TODO connection pool (share connection across requests)
# TODO multi-tanency design (same db for all users?)
# TODO LIST API limit count?
# TODO API failure 503? 500?
# TODO Complete the interface according to Parse
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

  def initialize
    @mongo = MongoClient.new
    @db = @mongo['test']
  end

  public

  # List all objects under class
  def index
    coll = @db[params[:className]]

    objs =  coll.find().to_a.each do |obj|
              obj.delete(MONGO_ID_KEY) 
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

    obj = JSON.parse(request.body.read)
    obj[OBJECT_ID_KEY] = SecureRandom.hex(OBJECT_ID_BYTE_LEN)
    obj[CREATION_TIME_KEY] = Time.now.utc

    id = coll.insert(obj)

    ret = Hash.new
    ret[OBJECT_ID_KEY] = obj[OBJECT_ID_KEY]
    ret[CREATION_TIME_KEY] = obj[CREATION_TIME_KEY]

    render json: ret, status: 201
  end

  # Retrieve the object 
  def show
    # get the data
    coll = @db[params[:className]]
    obj = coll.find(OBJECT_ID_KEY => params[:id]).to_a[0]
    obj.delete(MONGO_ID_KEY)

    # respond
    render json: obj 
  end

  # Update the object
  def update
    coll = @db[params[:className]]

    obj = JSON.parse(request.body.read)
    obj[UPDATE_TIME_KEY] = Time.now.utc
    coll.update({OBJECT_ID_KEY => params[:id]}, {'$set' => obj})

    ret = Hash.new
    ret[UPDATE_TIME_KEY] = obj[UPDATE_TIME_KEY]
    render json: ret
  end

  # Remove the object
  def destroy
    coll = @db[params[:className]]
    coll.remove(OBJECT_ID_KEY => params[:id])
    render nothing: true
  end

end
