*** Settings ***
Documentation    Suite description
Library  SeleniumLibrary
Library  OperatingSystem
Library  String
Library  Collections
Library  ../Libs/Helper.py


*** Variables ***
${URLS}

*** Test Cases ***
Feeds are valid
    @{url_list} =    Split String  ${URLS}  ,

    FOR  ${url}  IN  @{url_list}
        Feed is valid  ${url}

    END
#ensure required fields have vales


#id, title (max 150char), description (max 5k chars), link, image, availability, price, brand, condition

#Product fields have correct units
#ensure values with units have properly formatted units

#Product gtin is valid


#Product Description has proper encoding

*** Keywords ***

Feed is valid
    [Arguments]  ${url}
#    ${URL}=  Set Variable       https://www.poolwarehouse.com/wp-content/uploads/cart_product_feeds/Google/beefeater.xml
    ${outputName} =   get filename from url  ${url}

      ${outputDir} =    Set Variable    ${EMPTY}
#     ${rc}    ${output}    Run And Return Rc And Output    wget -O ${outputName} ${url}
    get feed  ${url}  ${outputName}
#     Move File    ${outputName}    /tmp/
#     ${xml}=  Parse XML  /tmp/${outputName}
     @{prods} =  parse xml    /tmp/${outputName}
     ${len} =  get length    ${prods}
     Log  ${len} items   console=True

     FOR    ${product}  IN   @{prods}
        ${link}=   get from dictionary  ${product}  link
        ${id}=       Get From Dictionary    ${product}  id
        LOG     evaluating product ${link} (${id})
#        LOG     ${product}
        Product Has Basic Fields  ${product}
        Product Has Conditionally Required Fields  ${product}
#        LOG  ${item}  console=True
     END

get filename from url
    [Arguments]  ${url}
    ${parts}=  Split String  ${url}     /
    ${len}=  get length     ${parts}
    ${ix}=  Evaluate  ${len}-1
    ${end}=  get from list  ${parts}    ${ix}
    [return]  ${end}

Product Has Basic Fields
    [Arguments]  ${prod}

    ${id}=       Get From Dictionary    ${prod}  id
    ${title}=    Get From Dictionary    ${prod}  title
    ${desc}=     Get From Dictionary    ${prod}  description
    ${img}=      Get From Dictionary    ${prod}  image_link
    ${avail}=    Get From Dictionary    ${prod}  availability
    ${cond}=     Get From Dictionary    ${prod}  condition
    ${price}=    Get From Dictionary    ${prod}  price
    ${brand}=    Get From Dictionary    ${prod}  brand


Product Has Conditionally Required Fields
    [Arguments]  ${prod}
    ${gtin}=    set variable  ${EMPTY}
    ${gtinstatus}    Run Keyword And Ignore Error   Get From Dictionary  ${prod}  gtin
    ${glen}=    get length  ${gtinstatus}
    ${gtin}=    set variable If  ${glen} == 2 and '${gtinstatus[0]}'=='PASS'   ${gtinstatus[1]}
    ${mpn}=    Get From Dictionary  ${prod}  mpn
    ${glen}=   set variable  0
    ${glen}=    run keyword If  ${glen} == 2 and '${gtinstatus[0]}'=='PASS'   get length  ${gtin}
    ${mlen}=    get length  ${mpn}
    Run Keyword If  ${glen} > 10     GTIN is valid  ${gtin}  ${mpn}      ELSE IF     ${mlen} > 0  MPN is valid  ${mpn}   ELSE    Fail  GTIN or MPN is required

# Must be 12-14 digits
# Must only be numeric
GTIN is valid
    [Arguments]  ${gtin}  ${mpn}
    ${len}=     get length  ${gtin}
    run keyword if  ${len} < 12 and ${len} > 14 and ${len} != 0    Fail  GTIN ${gtin} must be 12 digits
    should match regexp     ${gtin}  	^\\d{12,14}    GTIN must be only 12-14 digits
    MPN is valid  ${mpn}


# Max 70 alphanumeric characters
#
MPN is valid
    [Arguments]  ${mpn}
    ${mpn} =    get alpha  ${mpn}
    ${len} =     get length  ${mpn}
    run keyword if  ${len} > 70     Fail  MPN cannot exceed 70 characters
