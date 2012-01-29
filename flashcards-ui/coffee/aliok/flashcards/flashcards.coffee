class Context
  #adding time in milliseconds for breaking the browser cache.
  #we can of course do it with modifying JQuery.getJson function's options,
  #but in that case we will lose the nice syntax of it and use JQuery.ajax instead
  dataServiceUrl: () ->
    key = localStorage['userKey']
    time = new Date().getTime()
    val = "http://the-flashcards-data-service.appspot.com/data?userKey=#{ key }&time=#{ time }&callback=?"
    return val

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
        if Modernizr.websqldatabase
          view.alert "You answered all the words, so internet connection is required to get new words." +
            "Unable to connect server, please check your internet connection."
        else
          view.alert "Unable to connect server, please check your internet connection."

    @service.getNextWord callback


  start:()=>
    @view.registerPageCreateHandler @init
    #TODO: check for websql support somewhere
    @service.initializeDatabase (constructed) =>
      if not constructed
        @view.alert ('Unable to construct the local database!')


class Service
  constructor : (@context, @ajaxManager, @databaseManager) ->

  initializeDatabase: (callback) =>
    @databaseManager.initializeDatabase callback

  getNextWord :(callback) =>
    @databaseManager.checkIfWordStorageRefreshNecessary (refreshNecessary)=>
      if refreshNecessary
        @ajaxManager.getWords (data)=>
          unless data
            callback null
          else
            @constructWordStorage data, (article, translation, word)=>
              @databaseManager.setWordAsShown word, ()=> callback article, translation, word
      else
        @databaseManager.getNextWord (article, translation, word)=>
          @databaseManager.setWordAsShown word, ()=> callback article, translation, word

  constructWordStorage : (data, callback) =>
    @databaseManager.deleteAllWords (sqlError)=>
      if sqlError
        window.alert 'Unable to delete all words for reconstructing the word storage'
      else
        i = 0
        for obj in data
          do (obj) =>
            if i==0
              @databaseManager.addNewWordEntry obj['a'], obj['t'], obj['w'], () -> callback(obj['a'], obj['t'], obj['w'])
            else
              @databaseManager.addNewWordEntry obj['a'], obj['t'], obj['w']
            i++


class AjaxManager
  constructor : (@context) ->

  getWords : (callback)=>
    jqXHR = $.getJSON @context.dataServiceUrl(), (data)=>
      unless data
        callback null
      else
        if data['userKey']
          localStorage['userKey'] = data['userKey']
          console.log('Received user key :' + data['userKey'])
        callback data['entries']

    jqXHR.error () ->
      console.error 'Data call caused an error'
      callback null

class DatabaseManager
  constructor : ()->

  initializeDatabase : (callback) =>
    @database = openDatabase 'flashcards', '1.0', 'Flashcards Database', 2 * 1024 * 1024
    @database.transaction(
      (tx) -> tx.executeSql 'CREATE TABLE IF NOT EXISTS entry (article TEXT NOT NULL, translation TEXT NOT NULL, word TEXT NOT NULL, shown BOOLEAN NOT NULL)',
      (sqlError) -> callback false,
      () -> callback true
    )

  checkIfWordStorageRefreshNecessary : (callback) =>
    @database.transaction (tx) ->
      tx.executeSql(
        'select count(*) as notShownWordCount from entry where shown="false"',
        null,
        ((t,r) ->
          notShownWordCount = r.rows.item(0)['notShownWordCount']
          unless notShownWordCount
            callback true
          else
            callback false
        ),
        () ->
      )

  getNextWord : (callback) =>
    @database.transaction (tx) -> tx.executeSql(
      'select * from entry where shown="false" limit 1',
      null,
      ((t,r) ->
        item = r.rows.item(0)
        callback item['article'], item['translation'], item['word']
      ),
      ()->
    )

  addNewWordEntry : (article, translation, word, callback) =>
    @database.transaction(
      (tx) -> tx.executeSql "INSERT INTO entry values(?, ?, ?, 'false')", [article, translation, word] ,
      (sqlError) -> window.alert(sqlError),
      () => callback() if callback
    )

  deleteAllWords : (callback) =>
    @database.transaction(
      (tx) -> tx.executeSql 'DELETE from entry' ,
      (sqlError) -> callback sqlError ,
      () =>
        callback()
    )

  setWordAsShown : (word, callback) =>
    @database.transaction(
      (tx) -> tx.executeSql 'UPDATE entry set shown="true" where entry.word = ?', [word] ,
      (sqlError) -> callback sqlError,
      () -> callback()
    )

context = new Context()
view = new View()
service = new Service context, new AjaxManager(context), new DatabaseManager()
controller = new Controller view, service

controller.start()