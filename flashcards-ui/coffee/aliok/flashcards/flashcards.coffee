class Context
  #TODO: :-> or :()->
  websqlStorageSupport :-> Modernizr.websqldatabase

  #adding time in milliseconds for breaking the browser cache.
  #we can of course do it with modifying JQuery.getJson function's options,
  #but in that case we will lose the nice syntax of it and use JQuery.ajax instead
  dataServiceUrl:-> '/rest/mobileServices/wordService/nextWord?' + new Date().getTime()

class View
  registerPageCreateHandler      :(callback)->$('#mainPage' ).live 'pageinit', callback
  registerAnswerDerButtonHandler :(callback)->$('#answerDer').bind 'click', callback
  registerAnswerDieButtonHandler :(callback)->$('#answerDie').bind 'click', callback
  registerAnswerDasButtonHandler :(callback)->$('#answerDas').bind 'click', callback
  registerNextWordButtonHandler  :(callback)->$('#nextWord' ).bind 'click', callback

  setWord       :(word)->        $('#word').html word
  setTranslation:(translation)-> $('#translation').html translation
  setArticle    :(article)->     $('#article').html article
  setScore      :(score)->       $('#score').html score

  showLoadingDialog : ()-> $.mobile.showPageLoadingMsg()
  hideLoadingDialog : ()-> $.mobile.hidePageLoadingMsg()

  showResult : () ->
    $('#answers').hide()
    $('#article').show()
    $('#translation').show()
    $('#nextWordContainer').show()

  showChoices : () ->
    $('#answers').show()
    $('#article').hide()
    $('#translation').hide()
    $('#nextWordContainer').hide()

  setArticleColor : (correctAnswer)->
    if correctAnswer
      $('#article').attr 'class', 'correct'
    else
      $('#article').attr 'class', 'wrong'

  alert : (text)-> window.alert text

class Controller
  constructor: (@view, @service) ->
    @currentArticle = null
    @currentTranslation = null
    @score = 0

  init:()=>
    @view.registerAnswerDerButtonHandler @answerDer
    @view.registerAnswerDieButtonHandler @answerDie
    @view.registerAnswerDasButtonHandler @answerDas
    @view.registerNextWordButtonHandler  @nextWord
    @view.setScore 0
    @nextWord()

  answerDer:()=> @answer 'der'
  answerDie:()=> @answer 'die'
  answerDas:()=> @answer 'das'

  answer:(article) =>
    answerCorrect = (article==@currentArticle)
    if answerCorrect
      @score++
    else
      @score--
    @view.setArticleColor answerCorrect
    @view.setScore        @score
    @view.showResult()

  nextWord:()=>
    @view.showLoadingDialog()
    callback = (article, translation, word) =>
      if word?
        @currentArticle = article
        @currentTranslation = translation

        @view.showChoices()

        @view.setWord word
        @view.setTranslation @currentTranslation
        @view.setArticle @currentArticle

        @view.hideLoadingDialog()
      else
        @view.hideLoadingDialog()
        if Modernizr.websqldatabase()
          view.alert "You answered all the words, so internet connection is required to get new words." +
            "Unable to connect server, please check your internet connection."
        else
          view.alert "Unable to connect server, please check your internet connection."

    @service.getNextWord callback



class Service
  @constructor : () ->

  getNextWord :(callback) -> callback('das', 'book', 'Buch')



view = new View()
service = new Service()
controller = new Controller view, service

view.registerPageCreateHandler controller.init