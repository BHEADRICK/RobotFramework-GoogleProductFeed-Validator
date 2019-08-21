import urllib2
import re
import math
import xml.etree.ElementTree as ET


def get_feed(url):

    if(url.find('@')>-1):
        matchObj = re.match(r'(.*)//(.*):(.*)@(.*)', url)
        url = matchObj.group(1) + '//' + matchObj.group(4)
        user = matchObj.group(2)
        pw = matchObj.group(3)
        passman = urllib2.HTTPPasswordMgrWithDefaultRealm()
        passman.add_password(None, url,user, pw)
        auth_handler = urllib2.HTTPBasicAuthHandler(passman)
        opener = urllib2.build_opener(auth_handler)
        urllib2.install_opener(opener)
    # urllib2.urlopen("http://casfcddb.xxx.com")


    filedata = urllib2.urlopen(url)
    datatowrite = filedata.read()
    with open('/tmp/temp.xml', 'wb') as f:
        f.write(datatowrite)
    return parse_xml('/tmp/temp.xml')


def parse_xml(path):

    # xmlfile = filedata.read()
    # create element tree object 
    tree = ET.parse(path)

    # get root element 
    root = tree.getroot()

    # create empty list for product items 
    items = []

    # iterate product items 
    for item in root.findall('./channel/item'):
        # print(item.tag, child.attrib)
        # empty product dictionary 
        product = {}
        count = 0
        # iterate child elements of item 
        for child in item:

            # special checking for description
            if child.tag == 'g:additional_image_link':
                continue
            #     product[child.tag] = child.text.encode('utf8')
            else:
                product[child.tag.replace('{http://base.google.com/ns/1.0}','')] = child.text

                # append product dictionary to product items list 

        items.append(product)
        # print  product
        # print   '--------'
        # return product items list

    return items


def get_alpha(val):
    return re.sub('[^0-9a-zA-Z]+','', val)

def check_gtin_format(upc):
    upc = str(upc)
    p = re.compile('^\\d{12,14}$')
    m = p.match(upc)

    if m:

        valid = validate_gtin(upc)

        if valid:
            return ''
        else:
            return  'GTIN ' + upc + ' not valid (checksum error)'
    else:
        return 'GTIN (' + upc + ') must be only 12-14 digits'

def validate_gtin(upc):
    # print upc
    upc = str(upc).strip()
    checkdig = upc[len(upc)-1]
    upca = upc[0:len(upc)-1]
    # print upc
    # print upca
    # print checkdig


    if upc == '' or len(upc) < 12:
        return False

    return upc == get_check_digit(upca)



    # result should be last digit (check digit)
def get_check_digit(upc_str):
    """
    Returns a 12 digit upc-a string from an 11-digit upc-a string by adding
    a check digit
    >>> add_check_digit('02345600007')
    '023456000073'
    >>> add_check_digit('21234567899')
    '212345678992'
    >>> add_check_digit('04210000526')
    '042100005264'
    """

    upc_str = str(upc_str)
    # if len(upc_str) != 11:
    #     # raise Exception("Invalid length " + upc_str)
    #     return upc_str

    odd_sum = 0
    even_sum = 0
    for i, char in enumerate(upc_str):
        j = i+1
        if j % 2 == 0:
            even_sum += int(char)
        else:
            odd_sum += int(char)

    if len(upc_str) % 2 == 0:
        total_sum = (even_sum * 3) + odd_sum
    else:
        total_sum = (odd_sum * 3) + even_sum

    mod = total_sum % 10
    check_digit = 10 - mod
    if check_digit == 10:
        check_digit = 0

    # print check_digit
    return upc_str + str(check_digit)


# print get_check_digit('68914561091')

print check_gtin_format('788379665999 & 788379674359')

# def get_field(item, field):


# xml = parse_xml(get_feed('https://www.poolwarehouse.com/wp-content/uploads/cart_product_feeds/Google/beefeater.xml', 'beefeater.xml'))
# print len(xml)
# print(str(xml[3]))