require_relative '../models/state'

class CapitalPunishment
  get '/:dataset_type' do
    if session[:mode].nil?
      session[:mode] = :states
    end
    session[:message] = ''

    redirect "/#{params[:dataset_type]}/#{session[:mode].to_s}"
  end

  get '/:dataset_type/states' do
    @mode = :states
    @dataset_type = params[:dataset_type]
    states = State.where(type: @dataset_type).sample(5)
    question_state = states.first
    @state = question_state.name
    @state_id = question_state.id
    @all_answers = states.map{ |state| state.capital.sample }.shuffle
    @message = session[:message]

    erb :quiz
  end

  get '/:dataset_type/capitals' do
    @mode = :capitals
    @dataset_type = params[:dataset_type]
    states = State.where(type: @dataset_type).sample(5)
    question_state = states.first
    @capital = question_state.capital.sample
    @state_id = question_state.id
    @all_answers = states.map { |state| state.name}.shuffle
    @message = session[:message]

    erb :quiz
  end

  post '/:dataset_type/states/check_answer/:state_id' do
    state = State.find(params[:state_id])
    capital = state.capital
    answer = params[:answer].gsub('%20', ' ')

    session[:message] = capital.include?(answer) ? "<strong class=\"correct-answer\">Correct!</strong> The capital of #{state.name} <strong>is</strong> #{answer}." :
                                                   "<strong class=\"incorrect-answer\">Incorrect.</strong> The capital of #{state.name} <strong>is not</strong>  #{answer}."

    redirect "/#{params[:dataset_type]}/states"
  end

  post '/:dataset_type/capitals/check_answer/:state_id' do
    state =  State.find(params[:state_id])
    name = state.name
    caps = state.capital
    caps_string = caps.join(', ')
    answer = params[:answer].gsub('%20', ' ')
    session[:message] = name == answer ? "<strong class=\"correct-answer\">Correct!</strong> #{caps_string} #{caps.count > 1 ? "<strong>are</strong> capitals" : "<strong>is</strong> the capital"} of #{answer}." :
                                         "<strong class=\"incorrect-answer\">Incorrect.</strong> #{caps_string} #{caps.count > 1 ? "<strong>are not</strong> capitals" : "<strong>is not</strong> the capital"} of #{answer}."

    redirect "/#{params[:dataset_type]}/capitals"
  end

  post '/:dataset_type/states/toggle' do
    session[:mode] = :capitals
    @message = ''

    redirect "/#{params[:dataset_type]}/capitals"
  end

  post '/:dataset_type/capitals/toggle' do
    session[:mode] = :states
    @message = ''

    redirect "/#{params[:dataset_type]}/states"
  end
end
