

import urllib2
import re


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


# def get_field(item, field):


# xml = parse_xml(get_feed('https://www.poolwarehouse.com/wp-content/uploads/cart_product_feeds/Google/beefeater.xml', 'beefeater.xml'))
# print len(xml)
# print(str(xml[3]))