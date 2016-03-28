*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime
Library  dzo_service.py

*** Variables ***
${item_index}                      0
${locator.tenderId}                xpath=//td[contains(text(),'Ідентифікатор закупівлі')]/following-sibling::td[1]
${locator.title}                   xpath=//div[@class='topInfo']/h1
${locator.description}             xpath=//h2[@class='tenderDescr']
${locator.value.amount}            xpath=//span[contains(text(),'Очікувана вартість')]/.. /following-sibling::td/span[1]
${locator.legalName}               xpath=//td[contains(text(),'Найменування замовника')]/following-sibling::td//span
${locator.minimalStep.amount}      xpath=//td[contains(text(),'Розмір мінімального кроку пониження ціни')]/following-sibling::td/span[1]
${locator.enquiryPeriod.endDate}   xpath=//td[contains(text(),'Дата завершення періоду уточнень')]/following-sibling::td[1]
${locator.tenderPeriod.endDate}    xpath=//td[contains(text(),'Кінцевий строк подання тендерних пропозицій')]/following-sibling::td[1]
${locator.tenderPeriod.startDate}  xpath=//td[contains(text(),'Дата початку прийому пропозицій')]/following-sibling::td[1]
${locator.items.Description}    xpath=//div[${item_index} + 1]/table/tbody/tr[1]/td[2]
${locator.items.deliveryAddress.countryName}      xpath=//div[${item_index} + 1]/table/tbody/tr[5]/td[2]
${locator.items.deliveryAddress.postalCode}       xpath=//div[${item_index} + 1]/table/tbody/tr[5]/td[2]
${locator.items.deliveryAddress.locality}         xpath=//div[${item_index} + 1]/table/tbody/tr[5]/td[2]
${locator.items.deliveryAddress.streetAddress}    xpath=//div[${item_index} + 1]/table/tbody/tr[5]/td[2]
${locator.items.deliveryAddress.region}           xpath=//div[${item_index} + 1]/table/tbody/tr[5]/td[2]
${locator.items.deliveryDate.endDate}             xpath=//div[${item_index} + 1]/table/tbody/tr[6]/td[2]
${locator.items.classification.scheme}            xpath=//div[${item_index} + 1]/table/tbody/tr[2]/td[1]
${locator.items.classification.id}                xpath=//div[${item_index} + 1]/table/tbody/tr[2]/td[2]/span[1]
${locator.items.classification.description}       xpath=//div[${item_index} + 1]/table/tbody/tr[2]/td[2]/span[2]
${locator.items.additionalClassifications[0].scheme}         xpath=//div[${item_index} + 1]/table/tbody/tr[3]/td[1]
${locator.items.additionalClassifications[0].id}             xpath=//div[${item_index} + 1]/table/tbody/tr[3]/td[2]/span[1]
${locator.items.additionalClassifications[0].description}    xpath=//div[${item_index} + 1]/table/tbody/tr[3]/td[2]/span[2]
${locator.items.quantity}         xpath=//div[${item_index} + 1]/table/tbody/tr[4]/td[2]/span[1]
${locator.items.unit.code}        xpath=//div[${item_index} + 1]/table/tbody/tr[4]/td[2]/span[2]
${locator.items.unit.name}        xpath=//div[${item_index} + 1]/table/tbody/tr[4]/td[2]/span[2]
${locator.questions[0].title}        xpath=//div[@class = 'question relative']//div[@class = 'title']
${locator.questions[0].description}  xpath=//div[@class='text']
${locator.questions[0].date}         xpath=//div[@class='date']
${locator.questions[0].answer}       xpath=//div[@class = 'answer relative']//div[@class = 'text']
${locator.bids}                      xpath=//div[@class="qualificationBidAmount"]/span
${locator.currency}                  xpath=//span[contains(text(),'Очікувана вартість')]/.. /following-sibling::td/span[2]
${locator.tax}                       xpath=//span[@class='taxIncluded']


*** Keywords ***
Підготувати дані для оголошення тендера
  [Documentation]  Це слово використовується в майданчиків, тому потрібно, щоб воно було і тут
  [Arguments]  ${username}  ${tender_data}
    [return]  ${tender_data}

Підготувати клієнт для користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  ...      ${ARGUMENTS[0]} ==  username
  Open Browser
  ...      ${USERS.users['${ARGUMENTS[0]}'].homepage}
  ...      ${USERS.users['${ARGUMENTS[0]}'].browser}
  ...      alias=${ARGUMENTS[0]}
  Set Window Size       @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
#  Run Keyword And Ignore Error       Pre Login   ${ARGUMENTS[0]}
  Run Keyword If                     '${ARGUMENTS[0]}' != 'DZO_Viewer'   Login   ${ARGUMENTS[0]}

Login
  [Arguments]  @{ARGUMENTS}
  Wait Until Page Contains Element   jquery=a[href="/cabinet"]
  Click Element                      jquery=a[href="/cabinet"]
  Wait Until Page Contains Element   name=email   10
  Sleep  1
  Input text                         name=email      ${USERS.users['${ARGUMENTS[0]}'].login}
  Sleep  2
  Input text                         name=psw        ${USERS.users['${ARGUMENTS[0]}'].password}
  Wait Until Page Contains Element   xpath=//button[contains(@class, 'btn')][./text()='Вхід в кабінет']   20
  Click Element                      xpath=//button[contains(@class, 'btn')][./text()='Вхід в кабінет']

Pre Login
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ${login}=     Get Broker Property By Username  ${ARGUMENTS[0]}  login
  ${password}=  Get Broker Property By Username  ${ARGUMENTS[0]}  password
  Wait Until Page Contains Element  name=siteLogin  10
  Input Text                        name=siteLogin  ${login}
  Input Text                        name=sitePass   ${password}
  Click Button                      xpath=//*[@id='table1']/tbody/tr/td/form/p[3]/input

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
  ${username}=            Set Variable   ${ARGUMENTS[0]}
  ${tender_data}=         procuringEntity_name_dzo                                ${ARGUMENTS[1]}
  ${tender_data}=         Add_data_for_GUI_FrontEnds                              ${ARGUMENTS[1]}
  @{items}=               Get From Dictionary   ${ARGUMENTS[1].data}              items
#  @{lots}=                Get From Dictionary   ${ARGUMENTS[1].data}              lots
  ${title}=               Get From Dictionary   ${ARGUMENTS[1].data}              title
  ${description}=         Get From Dictionary   ${ARGUMENTS[1].data}              description
  ${budget}=              Get From Dictionary   ${ARGUMENTS[1].data.value}        amount
  ${currency}=            Get From Dictionary   ${ARGUMENTS[1].data.value}        currency
  ${tax}=                 Get From Dictionary   ${ARGUMENTS[1].data.value}        valueAddedTaxIncluded
  ${tax}=                 Convert To String     ${tax}
  ${tax}=                 Convert To Lowercase  ${tax}
#  ${step_rate}=          Get From Dictionary   ${ARGUMENTS[1].data.minimalStep}  amount
  ${enquiry_end_date}=    Get From Dictionary   ${ARGUMENTS[1].data.enquiryPeriod}   endDate
  ${enquiry_end_date}=    convert_date_to_slash_format   ${enquiry_end_date}
  ${end_date}=            Get From Dictionary   ${ARGUMENTS[1].data.tenderPeriod}    endDate
  ${end_date}=            convert_date_to_slash_format   ${end_date}
  Set Test Variable    ${username}
  Set Test Variable    ${tender_data}
  Set Test Variable    @{items}
#  Set Test Variable    @{lots}
  Set Test Variable    ${title}
  Set Test Variable    ${description}
  Set Test Variable    ${budget}
  Set Test Variable    ${enquiry_end_date}
  Set Test Variable    ${end_date}
  Set Test Variable    ${currency}
  Set Test Variable    ${tax}

 
  Selenium2Library.Switch Browser     ${ARGUMENTS[0]}
  Wait Until Page Contains Element    jquery=a[href="/tenders/new"]   30
  Click Element                       jquery=a[href="/tenders/new"]
  Run Keyword if   '${TEST NAME}' == 'Можливість оголосити однопредметний тендер'     Створити однопредметний тендер
  Run Keyword if   '${TEST NAME}' == 'Можливість оголосити багатопредметний тендер'   Створити багатопредметний тендер
  Run Keyword if   '${TEST NAME}' == 'Можливість оголосити мультилотовий тендер'      Створити мультилотовий тендер
  Run Keyword if   '${TEST NAME}' == 'Можливість оголосити однопредметний тендер з неціновим показником'    Створити тендер з неціновим показником
  [return]  ${Ids}


Створити однопредметний тендер
  Wait Until Page Contains Element    name=data[title]                     30
  Input text                          name=data[title]                     ${title}
  Input text                          name=data[description]               ${description}
  Select From List By Value           name=data[value][currency]           ${currency}
  Select From List By Value           name=data[value][valueAddedTaxIncluded]   ${tax}
  Input text                          name=data[enquiryPeriod][endDate]    ${enquiry_end_date}
  Input text                          name=data[tenderPeriod][endDate]     ${end_date}
  Click Element                       id=multiItems
  Input text                          name=data[value][amount]             ${budget}
  Input text                          name=data[minimalStep][amount]       100.10
  Додати предмет                      ${items[0]}                          0
  Click Element                       xpath=//button[@value='publicate']
  Wait Until Page Contains            Тендер опубліковано                  30
  ${tender_UAid}=                     Get Text                             ${locator.tenderId}  
  ${Ids}=                             Convert To String                    ${tender_UAid}
  Set Test Variable                   ${Ids}
  [return]   ${Ids}


Створити багатопредметний тендер
  Wait Until Page Contains Element    name=data[title]                    30
  Input text                          name=data[title]                    ${title}
  Input text                          name=data[description]              ${description}
  Input text                          name=data[enquiryPeriod][endDate]   ${enquiry_end_date}
  Input text                          name=data[tenderPeriod][endDate]    ${end_date}
  Click Element                       id=multiItems
  Input text                          name=data[value][amount]            ${budget}
  Input text                          name=data[minimalStep][amount]      100.10
  Додати багато предметів             @{items}
  Click Element                       xpath= //button[@value='publicate']
  Wait Until Page Contains            Тендер опубліковано                 30
  ${tender_UAid}=                     Get Text                            ${locator.tenderId}  
  ${Ids}=                             Convert To String                   ${tender_UAid}
  Set Test Variable                   ${Ids}
#  Run keyword if                     '${mode}' == 'multi'   Set Multi Ids   ${tender_UAid}
  [return]   ${Ids}


Створити мультилотовий тендер
  @{lots}=                Get From Dictionary   ${tender_data.data}              lots
  Wait Until Page Contains Element    name=data[title]                    30
  Select From List                    name=tender_type                    lots
  Click Element                       xpath=//a[@class="jBtn green"]
  Sleep   1
  Input text                          name=data[title]                    ${title}
  Input text                          name=data[description]              ${description}
  Input text                          name=data[enquiryPeriod][endDate]   ${enquiry_end_date}
  Input text                          name=data[tenderPeriod][endDate]    ${end_date}
  Click Element                       id=multiLots
  dzo.Створити лот                    ${username}       ${tender_data}     @{lots}
  Click Element                       xpath= //button[@value='publicate']
  Wait Until Page Contains            Тендер опубліковано                  30
  ${tender_UAid}=                     Get Text                             ${locator.tenderId}
  ${Ids}=                             Convert To String                    ${tender_UAid}
  Set Test Variable                   ${Ids}
  [return]   ${Ids}


Створити тендер з неціновим показником
  ${features}=                        Get From Dictionary   ${tender_data.data}   features
  ${enum}=                            Get From Dictionary   ${tender_data.data.features[0]}   enum
  Log Many   ${tender_data.data}
  Log Many   ${features}
  Select From List                    name=tender_type                     features
  Click Element                       xpath=//a[@class="jBtn green"]
  Sleep   1
  Wait Until Page Contains Element    name=data[title]                     30
  Input text                          name=data[title]                     ${title}
  Input text                          name=data[description]               ${description}
  Input text                          name=data[enquiryPeriod][endDate]    ${enquiry_end_date}
  Input text                          name=data[tenderPeriod][endDate]     ${end_date}
  Click Element                       id=multiItems
  Input text                          name=data[value][amount]             ${budget}
  Input text                          name=data[minimalStep][amount]       100.10
  Додати предмет                      ${items[0]}                          0
  Click Element                       id=multiFeatures
  Додати нецінові критерії            ${features}
  Click Element                       xpath= //button[@value='publicate']
  Wait Until Page Contains            Тендер опубліковано                  30
  ${tender_UAid}=                     Get Text                             ${locator.tenderId}
  ${Ids}=                             Convert To String                    ${tender_UAid}
  Set Test Variable                   ${Ids}
  [return]   ${Ids}


Додати нецінові критерії
  [Arguments]   ${features}
  Log Many    ${features[0]}
  Log Many    ${features}
  ${features_length}=   Get Length   ${features}
  : FOR    ${INDEX}    IN RANGE    0    ${features_length}
  \   Run Keyword if   ${INDEX} != 0      Click Element    xpath=//section[@id='multiFeatures']//a[contains(text(), 'Додати критерій')]
  \   Додати показник  ${features[${INDEX}]}   ${INDEX}


Додати показник
  [Arguments]   ${feature}  ${feature_index}
  ${code}=             Get From Dictionary      ${feature}        code
  ${description}=      Get From Dictionary      ${feature}        description
  ${description}=      Decode Bytes To String   ${description}    UTF-8
  ${enum}=             Get From Dictionary      ${feature}        enum
  ${enum_length}=      Get Length               ${enum}
  ${enum_title}=       Get From Dictionary      ${enum[0]}        title
  ${enum_title}=       Decode Bytes To String   ${enum_title}     UTF-8
  ${enum_value}=       Get From Dictionary      ${enum[0]}        value
  ${featureOf}=        Get From Dictionary      ${feature}        featureOf
  ${feature_title}=    Get From Dictionary      ${feature}        title
  ${feature_title}=    Decode Bytes To String   ${feature_title}  UTF-8
  ${code}=             Get From Dictionary      ${feature}        code

  Input text                  name=data[features][${feature_index}][title]              ${feature_title}
  Input text                  name=data[features][${feature_index}][description]        ${description}
  Select From List By Value   name=data[features][${feature_index}][featureOf]          ${featureOf}
  Run Keyword If   ${featureOf} == item    Select From List By Value   name=data[features][${feature_index}][relatedItem]   {feature_title}

  : FOR   ${index}   IN RANGE   0   ${enum_length}
  \   Run Keyword if   ${index} != 0    Click Element    xpath=//div[@class='tenderItemElement tenderFeatureItemElement'][${feature_index + 1}]//a[@class='addFeatureOptItem']
  \   Додати опцію   ${enum[${index}]}   ${index}   ${feature_index}

Додати опцію
  [Arguments]   ${enum}  ${index}  ${feature_index}
  ${enum_title}=       Get From Dictionary      ${enum}               title
  ${enum_title}=       Decode Bytes To String   ${enum_title}         UTF-8
  ${enum_value}=       Get From Dictionary      ${enum}               value
  ${enum_value}=       Convert To Integer       ${enum_value * 100}

  Input text                  name=data[features][${feature_index}][enum][${index}][title]     ${enum_title}
  Input text                  name=data[features][${feature_index}][enum][${index}][value]     ${enum_value}


Завантажити документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${Ids}

  Go to   ${USERS.users['${ARGUMENTS[0]}'].homepage}
  Click Element      xpath=//a[@href='/cabinet/tenders/purchase']
  Select From List By Value    name=filter[object]    tenderID
  Input Text      name=filter[search]       ${ARGUMENTS[2]}
  Focus           name=filter[search2]
  Click Button    xpath=//form[@name='filter']/div[2]/div[3]/div[2]/button[@type='submit']
  Sleep   2
  Click Element   xpath=//a[contains(@class, 'tenderLink')]
  Sleep   1
  Click Element   xpath=//a[contains(text(),'Редагувати')]
  Sleep   1
  Click Element   xpath=//h3[contains(text(),'Тендерна документація')]/following-sibling::a  
  Execute Javascript    $("body > div").removeAttr("style");
  Choose File     xpath=//table[@id='uploaded']/*//a[contains(@class, 'uploadFile')]  ${ARGUMENTS[1]}
  Sleep   2
  Reload Page
  Click Button    xpath=//button[@value='save']
  Sleep   3
  Capture Page Screenshot

Set Multi Ids
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[1]} ==  ${tender_UAid}
  Log Many    @{ARGUMENTS}
  Log      ${ARGUMENTS[1]}
  ${id}=    Get Text       ${locator.tenderId}  
  ${Ids}=   Create List    ${ARGUMENTS[1]}   ${id}

Додати предмет
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  items
  ...      ${ARGUMENTS[1]} ==  ${INDEX}
  ${description}=         Get From Dictionary   ${ARGUMENTS[0]}                       description
  ${quantity}=            Get From Dictionary   ${ARGUMENTS[0]}                       quantity
  ${countryName}=         Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}       countryName
  ${region}=              Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}       region
  ${region}=              convert_string_from_dict_dzo                                ${region}
  ${locality}=            Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}       locality
  ${streetAddress}=       Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}       streetAddress
  ${postalCode}=          Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}       postalCode
  ${delivery_end_date}=   Get From Dictionary   ${ARGUMENTS[0].deliveryDate}          endDate
  ${delivery_end_date}=   convert_date_to_slash_format                                ${delivery_end_date}  
  ${cpv}=                 Convert To String     Картонні коробки
  ${cpv_id}=              Get From Dictionary   ${ARGUMENTS[0].classification}        id  
  ${cpv_id1}=             Replace String        ${cpv_id}   -   _
  ${dkpp_desc1}=          Get From Dictionary   ${ARGUMENTS[0].additionalClassifications[0]}   description
  ${dkpp_id11}=           Get From Dictionary   ${ARGUMENTS[0].additionalClassifications[0]}   id
  ${dkpp_1id}=            Replace String        ${dkpp_id11}   .   _
  ${index} =                          Convert To Integer     ${ARGUMENTS[1]}
  ${index} =                          Convert To Integer     ${index}

  Execute Javascript                  $(".topFixed").remove();
  Wait Until Page Contains Element    name=data[items][${index}][description]
  Input text                          name=data[items][${index}][description]   ${description}
  Input text                          name=data[items][${index}][quantity]   ${quantity}
  Click Element                       xpath=//div[@class='listItems']/div[${index} + 1]//a[contains(@data-class, 'CPV')]
  Select Frame                        xpath=//iframe[contains(@src,'/js/classifications/universal/index.htm?lang=uk&shema=CPV&relation=true')]
  Input text                          id=search     ${cpv}
  Wait Until Page Contains            ${cpv_id}
  Click Element                       xpath=//a[contains(@id,'${cpv_id1}')]
  Click Element                       xpath=//*[@id='select']
  Unselect Frame
  Click Element                       xpath=//div[@class='listItems']/div[${index} + 1]//a[contains(@data-class, 'ДКПП;ДК015;ДК018;ДК003')]
  Select Frame                        xpath=//iframe[contains(@src,'/js/classifications/universal/index.htm?lang=uk&shema=ДКПП;ДК015;ДК018;ДК003;NONE&relation=true')]
  Input text                          id=search     ${dkpp_desc1}
  Wait Until Page Contains            ${dkpp_id11}
  Sleep   1
  Click Element                       xpath=//a[contains(@id,'${dkpp_1id}')]
  Click Element                       xpath=//*[@id='select']
  Unselect Frame
  Select From List By Label           name=data[items][${index}][country_id]                        ${countryName}
  Select From List By Label           name=data[items][${index}][region_id]                         ${region}
  Input text                          name=data[items][${index}][deliveryAddress][locality]         ${locality}
  Input text                          name=data[items][${index}][deliveryAddress][streetAddress]    ${streetAddress}
  Input text                          name=data[items][${index}][deliveryAddress][postalCode]       ${postalCode}
  Input text                          name=data[items][${index}][deliveryDate][endDate]             ${delivery_end_date}
  Capture Page Screenshot

Додати багато предметів
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  items
  Log Many    @{ARGUMENTS}
  ${Items_length}=   Get Length   ${ARGUMENTS}
  : FOR    ${INDEX}    IN RANGE    0    ${Items_length}
  \   Run Keyword if   ${INDEX} != 0      Click Element    xpath=//a[@class='addMultiItem']
  \   Додати предмет   ${ARGUMENTS[${INDEX}]}   ${INDEX}

Додати предмети закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} =  number
#  ${period_interval}=  Get Broker Property By Username  ${ARGUMENTS[0]}  period_interval
#  ${tender_data}=  prepare_test_tender_data  ${period_interval}  multi

  Log Many    @{ARGUMENTS}

  ${items}=         Get From Dictionary   ${ARGUMENTS[1].data}              items
  ${description}=   Get From Dictionary   ${items[0]}                       description
  ${quantity}=      Get From Dictionary   ${items[0]}                       quantity
  ${cpv}=           Convert To String     Картонки
  ${cpv_id}=        Get From Dictionary   ${items[0].classification}         id
  ${cpv_id1}=       Replace String        ${cpv_id}   -   _
  ${dkpp_desc}=     Get From Dictionary   ${items[0].additionalClassifications[0]}   description
  ${dkpp_id}=       Get From Dictionary   ${items[0].additionalClassifications[0]}   id
  ${dkpp_id1}=      Replace String        ${dkpp_id}   -   _

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Run keyword if   '${TEST NAME}' == 'Можливість додати позицію закупівлі в тендер'   додати позицію
  Run keyword if   '${TEST NAME}' != 'Можливість додати позицію закупівлі в тендер'   видалити позиції

додати позицію
  dzo.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains Element           xpath=//a[./text()='Редагувати']   30
  Click Element                              xpath=//a[./text()='Редагувати']
  Додати багато предметів     ${ARGUMENTS[2]}
  Wait Until Page Contains Element           xpath=//button[./text()='Зберегти']   30
  Click Element                              xpath=//button[./text()='Зберегти']

видалити позиції
  dzo.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains Element           xpath=//a[./text()='Редагувати']   30
  Click Element                              xpath=//a[./text()='Редагувати']
  : FOR    ${INDEX}    IN RANGE    1    ${ARGUMENTS[2]}-1
  \   sleep  5
  \   Click Element                          xpath=//a[@class='deleteMultiItem'][last()]
  \   sleep  5
  \   Click Element                          xpath=//a[@class='jBtn green']
  Wait Until Page Contains Element           xpath=//button[./text()='Зберегти']   30
  Click Element                              xpath=//button[./text()='Зберегти']

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderId
  Switch browser   ${ARGUMENTS[0]}
  Go To  ${USERS.users['${ARGUMENTS[0]}'].homepage}
  Wait Until Page Contains            Держзакупівлі.онлайн   10
  Click Element                       xpath=//a[text()='Закупівлі']
  Click Element                       xpath=//a[@href='/tenders/all']
  sleep  1
  Click Element                       xpath=//select[@name='filter[object]']/option[@value='tenderID']
  Input text                          xpath=//input[@name='filter[search]']  ${ARGUMENTS[1]}
  Focus                               name=filter[search2]
  Click Element                       xpath=//button[@class='btn not_toExtend'][./text()='Пошук']
  Wait Until Page Contains            ${ARGUMENTS[1]}   10
  Capture Page Screenshot
  sleep  3
  Click Element                       xpath=//a[@class='reverse tenderLink']
  Capture Page Screenshot

Задати питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderUaId
  ...      ${ARGUMENTS[2]} ==  questionId
  ${title}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=  Get From Dictionary  ${ARGUMENTS[2].data}  description

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  dzo.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  sleep  1
  Execute Javascript                  window.scroll(2500,2500)
  Wait Until Page Contains Element    xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]    20
  Click Element                       xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]
  Wait Until Page Contains Element    name=title    20
  Input text                          name=title                 ${title}
  Input text                          xpath=//textarea[@name='description']           ${description}
  Click Element                       xpath=//div[contains(@class, 'buttons')]//button[@type='submit']
  Wait Until Page Contains            ${title}   30
  Capture Page Screenshot
  Log Many   ${ARGUMENTS[2]}
  [return]   ${ARGUMENTS[2]}

Відповісти на питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = tenderUaId
  ...      ${ARGUMENTS[2]} = 0
  ...      ${ARGUMENTS[3]} = answer_data

  ${answer}=     Get From Dictionary  ${ARGUMENTS[3].data}  answer
  Selenium2Library.Switch Browser     ${ARGUMENTS[0]}

  dzo.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Execute Javascript                  window.scroll(1500,1500)
  Wait Until Page Contains Element    xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]    20
  Click Element                       xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]
  Sleep   1
  Wait Until Page Contains Element    xpath=//textarea[@name='answer']    20
  Input text                          xpath=//textarea[@name='answer']            ${answer}
  Click Element                       xpath=//form[@class='answer_form']//button
  Sleep   2
  Reload Page
  Wait Until Page Contains            ${answer}   30
  Capture Page Screenshot

Подати скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = tenderUaId
  ...      ${ARGUMENTS[2]} = complaintsId
  ${complaint}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=      Get From Dictionary  ${ARGUMENTS[2].data}  description

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  dzo.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  sleep  1
  Execute Javascript                 window.scroll(1500,1500)
  Click Element                      xpath=//a[@class='reverse openCPart'][span[text()='Скарги']]
  Wait Until Page Contains Element   name=title    20
  Input text                         name=title                 ${complaint}
  Input text                         xpath=//textarea[@name='description']           ${description}
  Click Element                      xpath=//div[contains(@class, 'buttons')]//button[@type='submit']
  Wait Until Page Contains           ${complaint}   30
  Capture Page Screenshot

Порівняти скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = tenderUaId
  ...      ${ARGUMENTS[2]} = complaintsData
  ${complaint}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=      Get From Dictionary  ${ARGUMENTS[2].data}  description

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  dzo.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  sleep  1
  Execute Javascript                 window.scroll(1500,1500)
  Click Element                      xpath=//a[@class='reverse openCPart'][span[text()='Скарги']]
  Wait Until Page Contains           ${complaint}   30
  Capture Page Screenshot

Внести зміни в тендер
  #  Тест написано для уже існуючого тендеру, що знаходиться у чернетках користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = description

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Execute Javascript                      $(".topFixed").remove();
  Click Element                      xpath=//a[@class='reverse'][./text()='Мої закупівлі']
  Wait Until Page Contains Element   xpath=//a[@class='reverse'][./text()='Чернетки']   30
  Click Element                      xpath=//a[@class='reverse'][./text()='Чернетки']
  Wait Until Page Contains Element   xpath=//a[@class='reverse tenderLink']    30
  Click Element                      xpath=//a[@class='reverse tenderLink']
  sleep  1
  Click Element                      xpath=//a[@class='button save'][./text()='Редагувати']
  sleep  1
  Input text                         name=data[title]   ${ARGUMENTS[1]}
  sleep  1
  Click Element                      xpath=//button[@class='saveDraft']
  Wait Until Page Contains           ${ARGUMENTS[1]}   30
  Capture Page Screenshot

Оновити сторінку з тендером
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = tenderUaId

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  dzo.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Reload Page


Отримати інформацію із запитання
  [Arguments]   @{ARGUMENTS}
  Log Many    @{ARGUMENTS}
  Run Keyword And Return  Отримати інформацію про ${ARGUMENTS[1]}


Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  fieldname
  ${item_index}=        Get Substring    ${ARGUMENTS[1]}    6    7
  Set Suite Variable    ${item_index}    ${item_index}
  Switch browser        ${ARGUMENTS[0]}
  Run Keyword And Return  Отримати інформацію про ${ARGUMENTS[1]}

Отримати текст із поля і показати на сторінці
  [Arguments]   ${fieldname}
  sleep  1
  ${return_value}=    Get Text  ${locator.${fieldname}}
  [return]  ${return_value}

Отримати інформацію про title
  ${title}=   Отримати текст із поля і показати на сторінці   title
  ${title}=   convert_title_dzo    ${title}
  [return]  ${title.split('.')[0]}

Отримати інформацію про description
  ${description}=   Отримати текст із поля і показати на сторінці   description
  [return]  ${description}


Отримати інформацію про tenderId
  ${tenderId}=   Отримати текст із поля і показати на сторінці   tenderId
  [return]  ${tenderId}

Отримати інформацію про value.amount
  ${valueAmount}=   Отримати текст із поля і показати на сторінці   value.amount
  ${valueAmount}=   Convert To Number   ${valueAmount.split(' ')[0]}
  [return]  ${valueAmount}

Отримати інформацію про minimalStep.amount
  ${minimalStepAmount}=   Отримати текст із поля і показати на сторінці   minimalStep.amount
  ${minimalStepAmount}=   Convert To Number   ${minimalStepAmount.split(' ')[0]}
  [return]  ${minimalStepAmount}

Отримати інформацію про enquiryPeriod.endDate
  ${enquiryPeriodEndDate}=   Отримати текст із поля і показати на сторінці   enquiryPeriod.endDate
  ${enquiryPeriodEndDate}=   subtract_from_time   ${enquiryPeriodEndDate}   6   5
  [return]  ${enquiryPeriodEndDate}

Отримати інформацію про tenderPeriod.endDate
  ${tenderPeriodEndDate}=   Отримати текст із поля і показати на сторінці   tenderPeriod.endDate
  ${tenderPeriodEndDate}=   subtract_from_time    ${tenderPeriodEndDate}   11   0
  [return]  ${tenderPeriodEndDate}

Отримати інформацію про items[${item_index}].deliveryAddress.countryName
  ${countryName}=   Отримати текст із поля і показати на сторінці   items.deliveryAddress.countryName
  [return]  ${countryName.split(',')[1].strip()}

Отримати інформацію про items[${item_index}].classification.scheme
  ${classificationScheme}=   Отримати текст із поля і показати на сторінці   items.classification.scheme
  [return]  ${classificationScheme.split(' ')[1]}

Отримати інформацію про items[${item_index}].additionalClassifications[0].scheme
  ${additionalClassificationsScheme}=   Отримати текст із поля і показати на сторінці   items.additionalClassifications[0].scheme
  ${additionalClassificationsScheme}=   convert_string_from_dict_dzo                    ${additionalClassificationsScheme.split(' ')[1]}
  [return]  ${additionalClassificationsScheme}

Отримати інформацію про questions[0].title
  #sleep  3
  #Click Element       xpath=//a[@class='reverse tenderLink']
  sleep  3
  Click Element        xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]
  ${questionsTitle}=   Отримати текст із поля і показати на сторінці    questions[0].title
  ${questionsTitle}=   Convert To Lowercase   ${questionsTitle}
  ${questionsTitle}=   Set Variable   ${questionsTitle.split(' (')[0]}
  [return]  ${questionsTitle.capitalize().split('.')[0] + '.'}

Отримати інформацію про questions[0].description
  ${questionsDescription}=   Отримати текст із поля і показати на сторінці   questions[0].description
  [return]  ${questionsDescription}

Отримати інформацію про questions[0].date
  ${questionsDate}=   Отримати текст із поля і показати на сторінці   questions[0].date
  log  ${questionsDate}
  [return]  ${questionsDate}

Отримати інформацію про questions[0].answer
#  sleep  2
#  Click Element                       xpath=//a[@class='reverse tenderLink']
  sleep  2
  Click Element         xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]
  ${questionsAnswer}=   Отримати текст із поля і показати на сторінці   questions[0].answer
  [return]  ${questionsAnswer}

Отримати інформацію про items[${item_index}].deliveryDate.endDate
  ${deliveryDateEndDate}=   Отримати текст із поля і показати на сторінці   items.deliveryDate.endDate
  ${deliveryDateEndDate}=   subtract_from_time    ${deliveryDateEndDate}   15   0
  [return]  ${deliveryDateEndDate}

Отримати інформацію про items[${item_index}].classification.id
  ${classificationId}=   Отримати текст із поля і показати на сторінці   items.classification.id
  [return]  ${classificationId}

Отримати інформацію про items[${item_index}].classification.description
  ${classificationDescription}=   Отримати текст із поля і показати на сторінці   items.classification.description
  ${classificationDescription}=   convert_string_from_dict_dzo                    ${classificationDescription}
#  Run Keyword And Return If  '${classificationDescription}' == 'Картонки'    Convert To String  Cartons
  [return]  ${classificationDescription}

Отримати інформацію про items[${item_index}].additionalClassifications[0].id
  ${additionalClassificationsId}=   Отримати текст із поля і показати на сторінці     items.additionalClassifications[0].id
  [return]  ${additionalClassificationsId}

Отримати інформацію про items[${item_index}].additionalClassifications[0].description
  ${additionalClassificationsDescription}=   Отримати текст із поля і показати на сторінці     items.additionalClassifications[0].description
#  ${additionalClassificationsDescription}=   Convert To Lowercase   ${additionalClassificationsDescription}
  [return]  ${additionalClassificationsDescription}

Отримати інформацію про items[${item_index}].quantity
  ${itemsQuantity}=   Отримати текст із поля і показати на сторінці     items.quantity
  ${itemsQuantity}=   Convert To Integer                                ${itemsQuantity}
  [return]  ${itemsQuantity}

Отримати інформацію про items[${item_index}].unit.code
#  ${unitCode}=   Отримати текст із поля і показати на сторінці     items.unit.code
#  Run Keyword And Return If  '${unitCode}'== 'кг'   Convert To String  KGM
#  [return]  ${unitCode}
   Log       | Код одиниці вимірювання не виводиться на ДЗО      console=yes

Отримати інформацію про procuringEntity.name
  ${legalName}=   Отримати текст із поля і показати на сторінці   legalName
  [return]  ${legalName}

Отримати інформацію про enquiryPeriod.startDate
  Log       | Viewer can't see this information on DZO        console=yes

Отримати інформацію про tenderPeriod.startDate
  ${tenderPeriodStartDate}=   Отримати текст із поля і показати на сторінці   tenderPeriod.startDate
  ${tenderPeriodStartDate}=   subtract_from_time    ${tenderPeriodStartDate}   11   0
  [return]  ${tenderPeriodStartDate}

Отримати інформацію про items[${item_index}].deliveryLocation.longitude
  Log       | Viewer can't see this information on DZO        console=yes

Отримати інформацію про items[${item_index}].deliveryLocation.latitude
  Log       | Viewer can't see this information on DZO        console=yes

Отримати інформацію про items[${item_index}].deliveryAddress.postalCode
  ${postalCode}=   Отримати текст із поля і показати на сторінці   items.deliveryAddress.postalCode
  [return]  ${postalCode.split(',')[0]}

Отримати інформацію про items[${item_index}].deliveryAddress.locality
  ${locality}=   Отримати текст із поля і показати на сторінці   items.deliveryAddress.locality
  [return]  ${locality.split(',')[3].strip()}

Отримати інформацію про items[${item_index}].deliveryAddress.streetAddress
  ${streetAddress}=   Отримати текст із поля і показати на сторінці   items.deliveryAddress.streetAddress
  ${streetAddress}=   Convert To String                               ${streetAddress}
  [return]  ${streetAddress.split(',')[4].strip()}

Отримати інформацію про items[${item_index}].deliveryAddress.region
  ${region}=    Отримати текст із поля і показати на сторінці   items.deliveryAddress.region
  ${region}=    Set Variable                                    ${region.split(',')[2].strip()}  
  ${region}=    convert_string_from_dict_dzo                    ${region}
  [return]    ${region}

Отримати інформацію про items[${item_index}].unit.name
  ${unitName}=   Отримати текст із поля і показати на сторінці     items.unit.name
  ${unitName}=   convert_string_from_dict_dzo    ${unitName}
  [return]  ${unitName}

Отримати інформацію про items[${item_index:[^las]+}].description
  ${itemsDescription}=   Отримати текст із поля і показати на сторінці     items.Description
  [return]  ${itemsDescription}

Отримати інформацію про bids
  ${bids}=    Отримати текст із поля і показати на сторінці   bids
  [return]  ${bids}

Отримати інформацію про value.currency
  ${currency}=   Отримати текст із поля і показати на сторінці   currency
  ${currency}=   convert_string_from_dict_dzo                    ${currency}
  [return]  ${currency}

Отримати інформацію про value.valueAddedTaxIncluded
  ${tax}=   Отримати текст із поля і показати на сторінці   tax
  ${tax}=   convert_string_from_dict_dzo                    ${tax}
  ${tax}=   Convert To Boolean                              ${tax}
  [return]  ${tax}


Подати цінову пропозицію
  [Arguments]    @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${test_bid_data}
  ${bid}=    Get From Dictionary          ${ARGUMENTS[2].data.value}              amount
  dzo.Пошук тендера по ідентифікатору     ${ARGUMENTS[0]}                         ${ARGUMENTS[1]}
  Run keyword if   '${TEST NAME}' != 'Неможливість подати цінову пропозицію до початку періоду подачі пропозицій першим учасником'
  ...    Wait Until Keyword Succeeds    10 x   60 s    
  ...    Дочекатися синхронізації для періоду подачі пропозицій
  Input Text                              name=data[value][amount]                ${bid}
  Click Button                            name=do
  Sleep   1
  Click Element                           xpath=//a[./text()= 'Закрити']
  Sleep   1
  Click Button                            name=pay
  Sleep   1
  Click Element                           xpath=//a[./text()= 'OK']
  [return]  ${Arguments[2]}

########## Видалити після встановлення коректних часових проміжків для періодів #######################
Дочекатися синхронізації для періоду подачі пропозицій
  Reload Page
  Wait Until Page Contains    Ваша пропозиція

Дочекатися синхронізації для періоду аукціон
  Reload Page
  Wait Until Page Contains    Кваліфікація учасників
########################################################################################################

Змінити цінову пропозицію
  [Arguments]    @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${amount}
  ...      ${ARGUMENTS[3]} ==  ${bid}
  Log Many    @{ARGUMENTS}
  dzo.Пошук тендера по ідентифікатору     ${ARGUMENTS[0]}                              ${ARGUMENTS[1]}
#  Run keyword if   '${TEST NAME}' == 'Неможливість змінити цінову пропозицію до 50000 після закінчення прийому пропозицій'
#  ...    Wait Until Keyword Succeeds    10 x   60 s    
#  ...    Дочекатися синхронізації для періоду аукціон
  Wait Until Page Contains                Ваша пропозиція                              10
  Sleep  1
  Click Element                           xpath=//a[@class='button save bidToEdit']
  Sleep  1
  Input text                              name=data[value][amount]                     ${ARGUMENTS[3]}
  Click Element                           xpath=//button[@value='save']
  Sleep  2
  Run Keyword And Ignore Error   Wait Until Page Contains                Підтвердіть зміни в пропозиції
  Run Keyword And Ignore Error   Input Text                              xpath=//div[2]/form/table/tbody/tr[1]/td[2]/div/input    203986723
  Run Keyword And Ignore Error   Click Element                           xpath=//button[./text()='Надіслати']
  [return]  ${Arguments[2]}

Скасувати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  bid_number
  dzo.Пошук тендера по ідентифікатору     ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
  Wait Until Page Contains                Ваша пропозиція                              10
  Click Element                           xpath=//a[@class='button save bidToEdit']
  Wait Until Page Contains                Відкликати пропозицію                        10
  Click Element                           xpath=//button[@value='unbid']
  Sleep   1
  Click Element                           xpath=//a[@class='jBtn green']
  Sleep   2
  Wait Until Page Contains                Підтвердіть зміни в пропозиції
  Input Text                              xpath=//div[2]/form/table/tbody/tr[1]/td[2]/div/input    203986723
  Click Element                           xpath=//button[./text()='Надіслати']
  Wait Until Page Contains                Вашу пропозицію відкликано    30
  Click Element                           xpath=//a[./text()= 'Закрити']
  [return]  ${Arguments[1]}

Завантажити документ в ставку
  [Arguments]  ${username}  ${filePath}  ${tenderId}
  dzo.Пошук тендера по ідентифікатору     ${username}    ${tenderId}
  Wait Until Page Contains                Ваша пропозиція                               10
  Click Element                           xpath=//a[@class='button save bidToEdit']
  Execute Javascript                      $("body > div").removeAttr("style");
  Log   ${filePath}
  Choose File                             xpath=/html/body/div[1]/form/input            ${filePath}
  Click Element                           xpath=//button[@value='save']


Завантаження документу  
  [Arguments]  ${username}  ${filePath}  ${tenderId}
  dzo.Пошук тендера по ідентифікатору     ${username}    ${tenderId}
  Wait Until Page Contains                Ваша пропозиція                               10
  Click Element                           xpath=//a[@class='button save bidToEdit']
  Execute Javascript                      $("body > div").removeAttr("style");
  Log   ${filePath}
  Choose File                             xpath=/html/body/div[1]/form/input            ${filePath}
  Run Keyword And Ignore Error    Click Element                           xpath=//button[@value='save']


Змінити документ в ставці
  [Arguments]   ${username}  ${filepath}  ${bidid}  ${docid}
  Execute Javascript                      $(".topFixed").remove();
  Sleep   1
#  Click Element                           xpath=//a[@class='button save bidToEdit']
  Execute Javascript                      $("body > div").removeAttr("style");
  Log   ${filePath}
  Choose File                             xpath=//input[@title='Завантажити оновлену версію']    ${filePath}
  Click Element                           xpath=//button[@value='save']

Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tenderId}
  Sleep   120
  dzo.Пошук тендера по ідентифікатору   ${username}    ${tenderId}
  ${url}=                               Get Element Attribute                     xpath=//section/h3/a[@class="reverse"]@href
  [return]  ${url}

Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tenderId}
  dzo.Пошук тендера по ідентифікатору   ${username}    ${tenderId}
  Click Element                         xpath=//a[@class="reverse getAuctionUrl"]
  Sleep   3
  ${url}=                               Get Element Attribute                     xpath=//a[contains(text(),"Перейдіть до редукціону")]@href
  [return]  ${url}


Створити лот
  [Arguments]  ${username}  ${tender}  @{lot}
  Log          ${username}
  Log Many     ${tender}
  Log Many     ${lot}
  @{items}=         Get From Dictionary   ${tender.data}          items
  ${title}=         Get From Dictionary   ${lot[0]}               title
  ${description}=   Get From Dictionary   ${lot[0]}               description
  ${value_amount}=  Get From Dictionary   ${lot[0]}               value
  ${value_amount}=  Get From Dictionary   ${value_amount}         amount
  ${step_amount}=   Get From Dictionary   ${lot[0]}               minimalStep
  ${step_amount}=   Get From Dictionary   ${step_amount}          amount

  Input text   name=data[lots][0][title]                 ${title}
  Input text   name=data[lots][0][description]           ${description}
  Input text   name=data[lots][0][value][amount]         34000
  Input text   name=data[lots][0][minimalStep][amount]   30
  Додати предмет   ${items[0]}   0


