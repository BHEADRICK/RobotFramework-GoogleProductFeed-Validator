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
Feeds should be valid
    @{url_list} =    Split String  ${URLS}  ,

    FOR  ${url}  IN  @{url_list}
        Feed should be valid  ${url}

    END
#ensure required fields have vales


#id, title (max 150char), description (max 5k chars), link, image, availability, price, brand, condition

#Product fields have correct units
#ensure values with units have properly formatted units

#Product gtin should bevalid


#Product Description has proper encoding

*** Keywords ***

Feed should be valid
    [Arguments]  ${url}
#    ${URL}=  Set Variable       https://www.poolwarehouse.com/wp-content/uploads/cart_product_feeds/Google/beefeater.xml

#     ${rc}    ${output}    Run And Return Rc And Output    wget -O ${outputName} ${url}
    @{prods} =  get feed  ${url}
#     Move File    ${outputName}    /tmp/
#     ${xml}=  Parse XML  /tmp/${outputName}
#     @{prods} =  parse xml    /tmp/${outputName}
#     ${len} =  get length    ${prods}
#     Log  ${len} items   console=True

     FOR    ${product}  IN   @{prods}
        product should be valid  ${product}
#        LOG  ${item}  console=True
     END

Product should be valid
    [Arguments]  ${product}
    ${link}=   get from dictionary  ${product}  link
    ${id}=       Get From Dictionary    ${product}  id
    LOG     evaluating product ${link} (${id})
    #        LOG     ${product}
    Product Has Basic Fields  ${product}
    Product Has Conditionally Required Fields  ${product}

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


    unit values should be valid   ${prod}



Product Has Conditionally Required Fields
    [Arguments]  ${prod}
    ${gtin}=    set variable  ${EMPTY}
    ${gtinstatus}    Run Keyword And Ignore Error   Get From Dictionary  ${prod}  gtin

    ${gtin}=    set variable If  '${gtinstatus[0]}'=='PASS'  ${gtinstatus[1]}

    ${mpnstat}    Run Keyword And Ignore Error    Get From Dictionary  ${prod}  mpn
    ${mpn}=    set variable If   '${mpnstat[0]}'=='PASS'    ${mpnstat[1]}
    ${mlen}=   set variable  0
    ${glen}=   set variable  0
    ${mlen}=    run keyword if  '${mpnstat[0]}'=='PASS'     get length  ${mpnstat[1]}
    ${glen}=    run keyword If  '${gtinstatus[0]}'=='PASS'   get length  ${gtinstatus[1]}

    Run Keyword If  ${glen} > 10     GTIN should be valid  ${gtin}  ${mpn}      ELSE IF     ${mlen} > 0  MPN should be valid  ${mpn}   ELSE    Fail  GTIN or MPN is required

# Must be 12-14 digits
# Must only be numeric
GTIN should be valid
    [Arguments]  ${gtin}  ${mpn}
    ${gtin}=     Evaluate  '${gtin}'.strip()
    ${len}=     get length  ${gtin}
    run keyword if  ${len} < 12 and ${len} > 14 and ${len} != 0    Fail  GTIN ${gtin} must be 12 digits
    should match regexp     ${gtin}  	^\\d{12,14}    GTIN must be only 12-14 digits
    MPN should be valid  ${mpn}


# Max 70 alphanumeric characters
#
MPN should be valid
    [Arguments]  ${mpn}
    ${mpn} =    get alpha  ${mpn}
    ${len} =     get length  ${mpn}
    run keyword if  ${len} > 70     Fail  MPN cannot exceed 70 characters


unit values should be valid
    [Arguments]   ${prod}
     ${weight}    Run Keyword And Ignore Error    Get From Dictionary    ${prod}  shipping_weight
    ${width}    Run Keyword And Ignore Error  Get From Dictionary    ${prod}  shipping_width
    ${length}     Run Keyword And Ignore Error    Get From Dictionary    ${prod}  shipping_length
    ${height}    Run Keyword And Ignore Error    Get From Dictionary    ${prod}  shipping_height
    ${price}=   Get From Dictionary    ${prod}  price

    ${pat}=   set Variable  [\\d.]* [a-z]*
    should match regexp     ${price}    ${pat}

    run keyword if  '${weight[0]}'=='PASS'  should match regexp     ${weight[1]}    ${pat}
    run keyword if  '${width[0]}'=='PASS'  should match regexp     ${width[1]}    ${pat}
    run keyword if  '${length[0]}'=='PASS'  should match regexp     ${length[1]}    ${pat}
    run keyword if  '${height[0]}'=='PASS'  should match regexp     ${height[1]}    ${pat}
