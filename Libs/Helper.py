import urllib2
import re
import math
import xml.etree.ElementTree as ET


def get_feed(url):
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


def validate_gtin(upc):
    # print upc
    upc = str(upc)
    sum = 0
    checkdig = upc[len(upc)-1]

    upc = (upc[:-1]).strip()
    # sum of odd positions
    for i in xrange(0,len(upc)-1, 2):
        if upc[i] != '':
            sum += int(upc[i])
    # multiply by 3
    sum *= 3

    sum2 = 0
    # sum of even positions (except last digit)
    for j in xrange(1,len(upc),2):
        if upc[j] != '':
            sum += int(upc[j])
    # subtract from next multiple of 10
    nextmult = int(math.ceil(sum / 10.0)) * 10
    ans = nextmult - sum
    return ans == int(checkdig)
    # result should be last digit (check digit)





# print validate_upc('638983000091')

# def get_field(item, field):


# xml = parse_xml(get_feed('https://www.poolwarehouse.com/wp-content/uploads/cart_product_feeds/Google/beefeater.xml', 'beefeater.xml'))
# print len(xml)
# print(str(xml[3]))