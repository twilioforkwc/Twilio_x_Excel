# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
unless Office
  document.getElementsByClassName("alert_message")[0].innerHTML = "オフラインです"
else
  Office.initialize = (reason)->
    numbers = []

    call_status = false

    bindId = null

    showIndicator = ()->
      div = document.createElement('div')
      div.style.width = '100%'
      div.style.height = '100%'
      div.style.textAlign = 'center'
      div.style.backgroundColor = '#FFF'
      div.style.opacity = '0.6'
      div.style.position = 'absolute'
      div.style.top = '0'
      div.id = 'loading'
      body = document.getElementsByTagName('body')[0]
      gif = document.createElement('img')
      gif.src = '<%= asset_path "loading.gif" %>'
      gif.style.marginTop = '200px'
      gif.style.width = '128px'
      gif.style.height = '102px'
      body.appendChild(div)
      div.appendChild(gif)
      return

    hideIndicator = ()->
      div = document.getElementById('loading')
      body = document.getElementsByTagName('body')[0]
      if div
        body.removeChild(div)
      return

    getTable = (rows)->
      table = new Office.TableData()
      table.headers = [["発信先電話番号", "発信元電話番号", "メッセージ", "終了メッセージ", "終了番号", "リトライ回数", "ステータス"]]
      table.rows = rows
      return table

    getFromNumber = ()->
      return $('#from_number').val()

    formatNumber = (number)->
      return "☎" + number.replace(/^\+81/, '0')
  
    make_a_call = (number, ok_at, retry, body, message, success, error)->
      if call_status
        return
      else
        pin = $.trim(Office.context.document.settings.get("pin"))
        $.ajax
          url: '/twilio/call'
          method: 'POST'
          data: "token=" + pin + "&call_history[phone_number]=" + number + "&call_history[ok_at]=" + ok_at + "&call_history[retry]=" + retry + "&call_history[body]=" + body + "&call_history[message]=" + message + "&call_history[from]=" + getFromNumber() + "&bindId=" + bindId
          success: (args)->
            hideIndicator()
            success(args)
          error: (args)->
            hideIndicator()
            error(args)

    # Office.jsのバグ？
    fixHeaders = ()->
      Office.select("bindings#" + bindId).getDataAsync((result)->
        rows = []
        for row, index in result.value.rows
          rows.push row
        table = getTable(rows)
        Office.select("bindings#" + bindId).setDataAsync(table)
      )
      return

    updateStatus = (i, message)->
      # TODO 更新時のロックを実装
      Office.select("bindings#" + bindId).getDataAsync((result)->
        unless result.status == 'failed'
          rows = []
          for row, index in result.value.rows
            if i == index
              rows.push [row[0], row[1], row[2], row[3], row[4], row[5], message]
            else
              rows.push row
          table = getTable(rows)
          Office.select("bindings#" + bindId).setDataAsync(table)
      )

    queue = {}
    counter = {}

    getStatusUpdate = (call_sid, row)->
      sid = call_sid
      i = row
      return ()->
        $.ajax
          url: '/twilio/get_status?call_sid=' + sid
          method: 'GET'
          success: (responseText)->
            response = JSON.parse(responseText)
            counter[sid] += 1
            if counter[sid] > 3
              clearInterval(queue[sid])
              delete queue[sid]
              delete counter[sid]
            switch response.status
              when 'completed'
                clearInterval(queue[sid])
                updateStatus(i, "通話完了（応答「" + response.ivr_result + "」）")
              when 'busy'
                clearInterval(queue[sid])
                updateStatus(i, "エラー（通話中）")
              when 'no-answer'
                clearInterval(queue[sid])
                updateStatus(i, "エラー（無応答）")
              when 'failed'
                clearInterval(queue[sid])
                updateStatus(i, "エラー")
              when 'canceled'
                clearInterval(queue[sid])
                updateStatus(i, "エラー（キャンセル）")
              else
                updateStatus(i, "通話処理中")
        return
  
    getSuccess = (row)->
      i = row
      return (response)->
        if response
          updateStatus(i, "通話開始")
          askStatus = getStatusUpdate(response, i)
          queue[response] = setInterval(askStatus, 10000)
          counter[response] = 0
        else
          updateStatus(i, "エラー")
        return

    getError = (row)->
      i = row
      return (res)->
        updateStatus(i, "エラー")
        return

    load_main_page = (pin)->
      $.ajax
        url: '/phone/'
        method: 'POST'
        data: "pin=" + pin
        error: ()->
          hideIndicator()
        success: (html)->
          $('.container').html(html)
          $('#select_cells').mouseover(()->
            $('#select_cells').attr('src', '<%= asset_path "select_0.png" %>')
          )
          $('#select_cells').mouseout(()->
            $('#select_cells').attr('src', '<%= asset_path "select.png" %>')
          )
          $('#select_cells').click(()->
            $('.alert_message').html("")
            # phone_numbersというバインディングを作成
            Office.context.document.bindings.releaseByIdAsync('phone_numbers', (result)->
              return
            )
            Office.context.document.bindings.addFromPromptAsync(Office.BindingType.Matrix, {id: 'phone_numbers'}, (result)->
              if result.status == Office.AsyncResultStatus.Failed
                $('.alert_message').html("選択された範囲は利用できません")
              else
                # バインディングの範囲からデータ読み込み
                Office.select('bindings#phone_numbers').getDataAsync((result)->
                  if result.status == Office.AsyncResultStatus.Failed
                    $('.alert_message').html("データを読み取れません")
                  else
                    numbers = result.value
                    if numbers.length <= 0
                      $('.alert_message').html("電話番号のセルを選択してください")
                    else if numbers[0].toString() == ""
                      $('.alert_message').html("電話番号のセルを選択してください")
                )
            )
          )
  
          $('#create_table').mouseover(()->
            $('#create_table').attr('src', '<%= asset_path "setup_0.png" %>')
          )
          $('#create_table').mouseout(()->
            $('#create_table').attr('src', '<%= asset_path "setup.png" %>')
          )
          $('#create_table').click(()->
            $('.alert_message').html("")
            #バインディング作成
            table = new Office.TableData()
            talbe = getTable([])
            table.rows.push(["☎︎", "☎︎", "4月6日 午後2時頃1丁目路上で児童が下校途中、声を掛けられました。ご注意下さい。お聞きになった方は1番を押して下さい。", "ありがとうございました。", "1", "1", "このセルはサンプルです"])
            table.rows.push(["☎︎", "☎︎", "5月10日 に予定しておりました運動会は、天候不順の為、来週に延期いたします。詳細は学校でお知らせいたします。お聞きになった方は1番を押して下さい。", "ありがとうございました。", "1", "1", "このセルはサンプルです"])
            table.rows.push(["☎︎", "☎︎", "3月30日 に第4会議室で定例会議を開催いたします。お時間を開けていただきますようお願い致します。お聞きになった方は1番を押して下さい。", "ありがとうございました。", "1", "1", "このセルはサンプルです"])
            for number in numbers
              table.rows.push [""+formatNumber(number.toString())+"", ""+formatNumber(getFromNumber())+"", "", "", "1", "1", "待機中"]
            myFormat = {fontStyle:"bold", width:"autoFit", borderColor:"purple"}
            Office.context.document.setSelectedDataAsync(table, {coercionType: "table", tableOptions: {bandedRows: true, filterButton: false, style:"TableStyleMedium3"}, cellFormat: []}, (result)->
              # tableをbindする前に同じIDをunbind
              bindId = "table" + (+new Date()) + "Data"
              Office.context.document.bindings.getByIdAsync(bindId, (checkResult)->
                #if checkResult.status == "failed"
                #if true
                # tableをbind
                Office.context.document.bindings.addFromSelectionAsync(Office.BindingType.Table, {id: bindId}, (res)->
                  if res.status == "failed"
                    $('.alert_message').html("ERROR:" + res.error.message)
                  else
                    fixHeaders()
                    $('#stop_call_button').mouseover(()->
                      $('#stop_call_button').attr('src', '<%= asset_path "stop_0.png" %>')
                    )
                    $('#stop_call_button').mouseout(()->
                      $('#stop_call_button').attr('src', '<%= asset_path "stop.png" %>')
                    )
                    $('#stop_call_button').click(()->
                      $('.alert_message').html("")
                      call_status = true
                      $.ajax
                        url: '/twilio/stop'
                        method: 'POST'
                        data: "token=" + pin
                    )
                    start_event = ()->
                      $('.alert_message').html("")
                      call_status = false
                      showIndicator()
                      Office.select('bindings#' + bindId).getDataAsync((result)->
                        if result.status == "failed"
                          $('.alert_message').html(result.error.message)
                        else
                          str = ""
                          rows = result.value.rows
                          for row,i  in rows
                            success = getSuccess(i)
                            error = getError(i)
                            if row[0] != '☎︎'
                              make_a_call(row[0], row[4], row[5], row[2], row[3], success, error)
                        return
                      )
                      return
                    $('#start_call_button').unbind(start_event)
                    $('#start_call_button').mouseover(()->
                      $('#start_call_button').attr('src', '<%= asset_path "start_0.png" %>')
                    )
                    $('#start_call_button').mouseout(()->
                      $('#start_call_button').attr('src', '<%= asset_path "start.png" %>')
                    )
                    $('#start_call_button').click(start_event)
                  )
                #else
                  # テーブルデータの削除は動作しない
                  #binding = checkResult.value
                  #binding.deleteAllDataValuesAsync(null, (e)->
                  #  if e.error
                  #    $('.alert_message').html("以前作成したテーブルを削除できませんでした")
                  #  else
                  #    $('.alert_message').html("以前作成したテーブルを削除しました")
                  #)
                  #$('.alert_message').html("同じシートに複数の通話情報テーブルを作成することはできません")
                  #return
              )
              return
            )
          )
          hideIndicator()
          return
        error: ()->
          #$('.login_form').removeClass('hidden')
          #$('.start_form').addClass('hidden')
          $('.alert_message').html("アカウント情報に誤りがあります")
          hideIndicator()
  
    $(document).ready(()->
      pin = $.trim(Office.context.document.settings.get("pin"))
      if pin
        $('#auth_login').mouseover(()->
          $('#auth_login').attr('src', '<%= asset_path 'login.png' %>')
        )
        $('#auth_login').mouseout(()->
          $('#auth_login').attr('src', '<%= asset_path 'login06.png' %>')
        )
        $('.start_form').removeClass('hidden')
        $('#auth_login').click(()->
          $('.alert_message').html("")
          showIndicator()
          load_main_page(pin)
          return
        )
      else
        $('.start_form').addClass('hidden')

      $('#login_off').mouseover(()->
        $('#login_off').attr('src', '<%= asset_path 'bj.png' %>')
      )
      $('#login_off').mouseout(()->
        $('#login_off').attr('src', '<%= asset_path 'b.png' %>')
      )
      $('#login_off').click(()->
        $('.alert_message').html("")
        $('#login_off').addClass('hidden')
        $('#login_on').removeClass('hidden')
        $('#new_user_app').submit()
        return
      )
      $('#new_user_app').on("submit", ()->
        $('.alert_message').html("")
        showIndicator()
        return
      )
      $('#new_user_app').on("ajax:success", (e, data, status, xhr)->
        $('#login_off').removeClass('hidden')
        $('.alert_message').html("")
        $('#login_on').addClass('hidden')
        pin = $.trim(data)
        Office.context.document.settings.set("pin", pin)
        Office.context.document.settings.saveAsync(()->
          load_main_page(pin)
        )
        return
      ).bind "ajax:error", (e, xhr, status, error) ->
        $('#login_off').removeClass('hidden')
        $('#login_on').addClass('hidden')
        hideIndicator()
        $('.alert_message').removeClass('hidden')
        $('.alert_message').html(xhr.responseText)
        return
    )
    return

