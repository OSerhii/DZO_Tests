 #!/usr/bin/python
 # -*- coding: utf-8 -*-

from datetime import datetime, timedelta


def subtract_from_time(date_time, subtr_min, subtr_sec):
    sub = datetime.strptime(date_time, "%d.%m.%Y %H:%M")
    sub = (sub - timedelta(minutes=int(subtr_min),
                           seconds=int(subtr_sec))).isoformat()
    return sub

def procuringEntity_name_dzo(INITIAL_TENDER_DATA):
    INITIAL_TENDER_DATA.data.procuringEntity['name'] = u"ПрАТ <Комбайн Інк.>"
    return INITIAL_TENDER_DATA

def convert_title_dzo(string):
    return string.replace(string[14:], string[14:].lower())

def convert_string_from_dict_dzo(string):
    return {
        u"м. Київ": u"Київська область",
        u"Київська область": u"м. Київ",
        u"кг": u"кілограм",
        u"грн": u"UAH",
        u"(з ПДВ)": u"True",
        u"(без ПДВ)": u"False",
        u"Картонні коробки": u"Картонки",
        u"ДК": u"ДКПП",
    }.get(string, string)
