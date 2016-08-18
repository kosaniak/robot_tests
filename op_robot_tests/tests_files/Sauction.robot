*** Settings ***
Resource        keywords.robot
Resource        resource.robot
Suite Setup     Test Suite Setup
Suite Teardown  Test Suite Teardown
Library         DebugLibrary

*** Variables ***
@{used_roles}   viewer


*** Test Cases ***

Можливість знайти закупівлю по ідентифікатору
  [Tags]   ${USERS.users['${viewer}'].broker}: Пошук тендера
  ...      ${USERS.users['${viewer}'].broker}
  ...      find_tender  level1
  Завантажити дані про тендер
  Run As  ${viewer}  Пошук тендера по ідентифікатору   ${TENDER['TENDER_UAID']}

##############################################################################################
#             AUCTION
##############################################################################################

Відображення дати початку аукціону
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення основних даних аукціону
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      tender_view  level2
  [Setup]  Дочекатись дати закінчення прийому пропозицій  ${viewer}  ${TENDER['TENDER_UAID']}
  Дочекатись дати початку періоду аукціону  ${viewer}  ${TENDER['TENDER_UAID']}
  Отримати дані із тендера  ${viewer}  ${TENDER['TENDER_UAID']}  auctionPeriod.startDate  ${TENDER['LOT_ID']}


Можливість дочекатися початку аукціону
  [Tags]   ${USERS.users['${viewer}'].broker}: Процес аукціону
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      auction
  Дочекатись дати початку аукціону  ${viewer}


Можливість вичитати посилання на аукціон для глядача
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення основних даних аукціону
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      auction  level1
  Можливість вичитати посилання на аукціон для ${viewer}



Можливість дочекатись першого раунду
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення основних даних аукціону
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      auction  level1
  Відкрити сторінку аукціону для ${viewer}
  Дочекатись паузи перед першим раундом  ${viewer}
  Дочекатись завершення паузи перед першим раундом  ${viewer}


Можливість проведення 1 го раунду аукціону для глядача
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення основних даних аукціону
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      auction  level1
  Дочекатись закінчення стадії ставок  ${viewer}


Можливість дочекатись другого раунду
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення основних даних аукціону
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      auction  level1
  Дочекатись завершення паузи перед раундом  ${viewer}


Можливість проведення 2 го раунду аукціону для глядача
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення основних даних аукціону
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      auction  level1
  Дочекатись закінчення стадії ставок  ${viewer}


Можливість дочекатись третього раунду
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення основних даних аукціону
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      auction  level1
  Дочекатись завершення паузи перед раундом  ${viewer}


Можливість проведення 3 го раунду аукціону для глядача
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення основних даних аукціону
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      auction  level1
  Дочекатись оголошення результатів  ${viewer}


Можливість дочекатися завершення аукціону
  [Tags]   ${USERS.users['${viewer}'].broker}: Процес аукціону
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      auction
  [Teardown]  Оновити LAST_MODIFICATION_DATE
  Дочекатись дати закінчення аукціону користувачем ${viewer}


Відображення дати завершення аукціону
  [Tags]   ${USERS.users['${viewer}'].broker}: Відображення основних даних аукціону
  ...      viewer
  ...      ${USERS.users['${viewer}'].broker}
  ...      tender_view
  [Setup]  Дочекатись синхронізації з майданчиком  ${viewer}
  Отримати дані із тендера  ${viewer}  ${TENDER['TENDER_UAID']}  auctionPeriod.endDate  ${TENDER['LOT_ID']}


*** Keywords ***
Дочекатись дати початку аукціону
  [Arguments]  ${username}
  # Can't use that dirty hack here since we don't know
  # the date of auction when creating the procurement :)
  ${auctionStart}=  Отримати дані із тендера   ${username}  ${TENDER['TENDER_UAID']}   auctionPeriod.startDate  ${TENDER['LOT_ID']}
  Дочекатись дати  ${auctionStart}
  Оновити LAST_MODIFICATION_DATE
  Дочекатись синхронізації з майданчиком  ${username}


Можливість вичитати посилання на аукціон для ${username}
  ${url}=  Run As  ${username}  Отримати посилання на аукціон для глядача  ${TENDER['TENDER_UAID']}  ${TENDER['LOT_ID']}
  Should Be True  '${url}'
  Should Match Regexp  ${url}  ^https?:\/\/auction(?:-sandbox)?\.openprocurement\.org\/tenders\/([0-9A-Fa-f]{32})
  Log  URL аукціону для глядача: ${url}


Відкрити сторінку аукціону для ${username}
  ${url}=  Run as  ${username}  Отримати посилання на аукціон для глядача  ${TENDER['TENDER_UAID']}  ${TENDER['LOT_ID']}
  # ${auction_document}=  get_auction_document_by_link  ${url}
  # ${auction_document.current_stage}
  # ${auction_document.stages[0].start}
  # ${auction_document.stages[auction_document.current_stage+1].start}
  Open browser  ${url}  ${USERS.users['${username}'].browser}


Дочекатись дати закінчення аукціону користувачем ${username}
  ${status}  ${_}=  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  61 times  30 s  Page should contain  Аукціон завершився
  Run Keyword If  '${status}' == 'FAIL'
  ...      Run Keywords
  ...      Отримати дані із тендера  ${username}  ${TENDER['TENDER_UAID']}  auctionPeriod.startDate  ${TENDER['LOT_ID']}
  ...      AND
  ...      Дочекатись дати початку аукціону  ${username}
  ...      AND
  ...      Дочекатись дати закінчення аукціону користувачем ${username}
  ...      ELSE
  ...      Run Keywords
  ...      Wait Until Keyword Succeeds  5 times  30 s  Page should not contain  очікуємо на розкриття імен учасників
  ...      AND
  ...      Close browser


Дочекатись до завершення аукціону без розкриття імен учасників
  [Arguments]    ${timeout}=10 min
  Wait Until Page Contains      Очікуємо на розкриття імен учасників.  ${timeout}


Перевірити інформацію про тендер
  Page Should Contain   ${TENDER['title']}                    # tender title
  Page Should Contain   ${TENDER['procuringEntity']['name']}  # tender procuringEntity name


Дочекатись до завершення аукціону
  [Arguments]    ${timeout}=5 min
  Wait Until Page Does Not Contain   Очікуємо на розкриття імен учасників.  ${timeout}
  Wait Until Page Contains      Аукціон завершився   ${timeout}


Дочекатись паузи перед першим раундом
  [Arguments]  ${username}
  ${status}  ${_}=  Run Keyword And Ignore Error  Page should contain  Очікування
  Run Keyword If  '${status}' == 'PASS'
  ...      Run Keywords
  ...      Дочекатись дати початку аукціону  ${username}
  ...      AND
  ...      Wait Until Keyword Succeeds  5 times  30 s  Page should contain   до початку раунду


Дочекатись завершення паузи перед раундом
  [Arguments]  ${username}
  ${status}  ${_}=  Run Keyword And Ignore Error  Page should contain  до початку раунду
  Run Keyword And Return If  '${status}' == 'FAIL'  Get Current Date
  ${date}=  Get Current Date
  Wait Until Keyword Succeeds  15 times  30 s  Page should not contain  до початку раунду
  ${new_date}=  Get Current Date
  ${time}=  Subtract Date From Date  ${new_date}  ${date}
  Should Be True  ${time} < 140 and ${time} > 100
  # Wait Until Page Does Not Contain    до початку раунду    5 min


Дочекатись завершення паузи перед першим раундом
  [Arguments]  ${username}
  ${status}  ${_}=  Run Keyword And Ignore Error  Page should contain  до початку раунду
  Run Keyword And Return If  '${status}' == 'FAIL'  Get Current Date
  ${date}=  Get Current Date
  Wait Until Keyword Succeeds  15 times  30 s  Page should not contain  до початку раунду
  ${new_date}=  Get Current Date
  ${time}=  Subtract Date From Date  ${new_date}  ${date}
  Should Be True  ${time} < 320 and ${time} > 270


Дочекатись закінчення стадії ставок
  [Arguments]  ${username}
  ${status}  ${_}=  Run Keyword And Ignore Error  Page should contain  до закінчення раунду
  Run Keyword And Return If  '${status}' == 'FAIL'  Get Current Date
  ${date}=  Get Current Date
  Wait Until Keyword Succeeds  15 times  30 s  Page should not contain  до закінчення раунду
  ${new_date}=  Get Current Date
  ${time}=  Subtract Date From Date  ${new_date}  ${date}
  Should Be True  ${time} < 260 and ${time} > 210


Дочекатись оголошення результатів
  [Arguments]  ${username}  ${timeout}=4 min
  ${status}  ${_}=  Run Keyword And Ignore Error  Page should contain  до оголошення результатів
  Run Keyword And Return If  '${status}' == 'FAIL'  Get Current Date
  ${date}=  Get Current Date
   Wait Until Keyword Succeeds  15 times  30 s  Page should not contain  до оголошення результатів
  ${new_date}=  Get Current Date
  ${time}=  Subtract Date From Date  ${new_date}  ${date}
  Should Be True  ${time} < 260 and ${time} > 210


