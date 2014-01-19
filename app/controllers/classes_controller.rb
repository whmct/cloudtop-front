class ClassesController < ApplicationController
  public

  def index
    hello_world 
  end

  def create
    hello_world 
  end

  def show
    hello_world 
  end

  def update
    hello_world 
  end

  def destroy
    hello_world 
  end

  private

  def hello_world
    @test = Hash.new
    @test[:test] = "hello world"
    @test[:controller] = params[:controller]
    @test[:action] = params[:action]
    render json: @test
  end 
end
