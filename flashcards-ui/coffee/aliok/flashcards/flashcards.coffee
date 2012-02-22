#Copyright [2011] [Ali Ok - aliok AT apache org]
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.


###
ask user what to do when all words are shown
add info link (src, etc)
offline support
show current set number on the ui
allow fetching a set by number
next word button, previous word button
score mode / training mode
###

class Context
  #adding time in milliseconds for breaking the browser cache.
  #we can of course do it with modifying JQuery.getJson function's options,
  #but in that case we will lose the nice syntax of it and use JQuery.ajax instead
  dataServiceUrl: () ->
    key = localStorage['userKey']
    time = new Date().getTime()
    if key
      val = "http://the-flashcards-data-service.appspot.com/data?userKey=#{ key }&time=#{ time }&callback=?"
    else
      val = "http://the-flashcards-data-service.appspot.com/data?time=#{ time }&callback=?"

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

  askToFetchNextSet : (callback) =>
    $.mobile.changePage( "confirmFetchNextSet.html", {
      transition: "pop",
      reverse: false,
      changeHash: false
    });

    goBackToIndex = () =>
      $.mobile.changePage( "index.html", {
        transition: "pop",
        reverse: true,
        changeHash: false
      });

    $('#nextSetFetchConfirmationYesButton').live 'click', ()=>
      $('#nextSetFetchConfirmationYesButton').die 'click'
      goBackToIndex()
      callback(true)

    $('#nextSetFetchConfirmationNoButton').live 'click', ()=>
      $('#nextSetFetchConfirmationNoButton').die 'click'
      goBackToIndex()
      callback(false)

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

    showNextWord = ()=>
      @service.getNextWord (article, translation, word)=>
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
          #TODO: view.alert "Unable to connect server, please check your internet connection."
          @view.alertConnectionProblem()

    setWordsAsNonShownAndShowNextWord = ()=>
      @service.setWordsAsNonShown ()=>
        showNextWord()

    @service.checkAllShown (allShown) =>
      if allShown
        @view.askToFetchNextSet (fetchNextSet) =>
          if fetchNextSet
            @service.fetchNextSet (success)=>
              if success
                showNextWord()
              else
                @view.alertConnectionProblem()
                ##TODO
                @view.alertShowingCurrentSet()
                setWordsAsNonShownAndShowNextWord()
          else
            setWordsAsNonShownAndShowNextWord()
      else
        showNextWord()

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
    @databaseManager.getNextWord (article, translation, word)=>
      @databaseManager.setWordAsShown word, ()=> callback article, translation, word

  checkAllShown: (callback) =>
    @databaseManager.checkAllShown callback

  setWordsAsNonShown: (callback) =>
    @databaseManager.setWordsAsNonShown callback

  fetchNextSet: (callback) =>
    @ajaxManager.fetchNextSet (data)=>
      unless data
        callback false
      else
        @constructWordStorage data, ()-> callback(true)

  constructWordStorage : (data, callback) =>
    @databaseManager.deleteAllWords (sqlError)=>
      if sqlError
        window.alert 'Unable to delete all words for reconstructing the word storage'
      else
        @databaseManager.addNewWordEntries data, callback

class AjaxManager
  constructor : (@context) ->

  fetchNextSet : (callback)=>
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

  checkAllShown : (callback) =>
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

  addNewWordEntries : (words, callback) =>
    escape = (str)-> str.replace "'", "''"

    sql = "INSERT INTO entry "

    i = 0
    for obj in words
      do (obj) =>
        article = escape obj['a']
        translation = escape obj['t']
        word = escape obj['w']

        if i==0
          sql += "SELECT '#{ article }' as 'article', '#{ translation }' as 'translation', '#{ word }' as 'word', 'false' as 'shown' "
        else
          sql += "UNION SELECT '#{ article }', '#{ translation }', '#{ word }', 'false' "
        i++

    sql += ";"

    console.log sql

    @database.transaction(
      (tx) -> tx.executeSql sql, null ,
      ((sqlError) ->
        console.log(sqlError)
        window.alert(sqlError)
      ),
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

  setWordsAsNonShown: (callback) =>
    @database.transaction(
      (tx) -> tx.executeSql 'UPDATE entry set shown="false"', null ,
      (sqlError) -> callback sqlError,
      () -> callback()
    )

context = new Context()
view = new View()
service = new Service context, new AjaxManager(context), new DatabaseManager()
controller = new Controller view, service

controller.start()