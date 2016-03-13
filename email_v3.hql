create external table email_input (
app_id String,
platform String,
collector_tstamp String,
collector_year String,
collector_month String,
collector_day String,
dvce_tstamp String,
event String,
event_vendor String,
event_id String,
txn_id String,
v_tracker String,
v_collector String,
v_etl String,
user_id String,
user_ipaddress String,
user_fingerprint String,
domain_userid String,
domain_sessionidx String,
network_userid String,
geo_country String,
geo_region String,
geo_city String,
geo_zipcode String,
geo_latitude String,
geo_longitude String,
page_url String,
page_title String,
page_referrer String,
page_urlscheme String,
page_urlhost String,
page_urlport String,
page_urlpath String,
page_urlquery String,
page_urlfragment String,
refr_urlscheme String,
refr_urlhost String,
refr_urlport String,
refr_urlpath String,
refr_urlquery String,
refr_urlfragment String,
refr_medium String,
refr_source String,
refr_term String,
mkt_medium String,
mkt_source String,
mkt_term String,
mkt_content String,
mkt_campaign String,
se_category String,
se_action String,
se_label String,
se_property String,
se_value String,
tr_orderid String,
tr_affiliation String,
tr_total String,
tr_tax String,
tr_shipping String,
tr_city String,
tr_state String,
tr_country String,
tr_currency String,
ti_orderid String,
ti_sku String,
ti_name String,
ti_category String,
ti_price String,
ti_quantity String,
pp_xoffset_min String,
pp_xoffset_max String,
pp_yoffset_min String,
pp_yoffset_max String,
useragent String,
y_fingerprint String,
br_family String,
br_major String,
br_minor String,
br_lang String,
br_features_pdf String,
br_features_flash String,
br_features_java String,
br_features_director String,
br_features_quicktime String,
br_features_realplayer String,
br_features_windowsmedia String,
br_features_gears String,
br_features_silverlight String,
br_cookies String,
br_colordepth String,
br_viewwidth String,
br_viewheight String,
os_family String,
os_major String,
os_minor String,
os_timezone String,
device_family String,
dvce_screenwidth String,
dvce_screenheight String,
doc_charset String,
doc_width String,
doc_height String,
se_page_sku String
) row format delimited fields terminated by '\t' lines terminated by '\n' stored as textfile LOCATION '${INPUT}';


create EXTERNAL table email_traffic (app_key String, e_traffic String);
create EXTERNAL table general_traffic (app_key String, g_traffic String);
create EXTERNAL table email_tr (app_key String, e_tr String);
create EXTERNAL table general_tr (app_key String, g_tr String);
create EXTERNAL table etotal (app_key String, e_traffic String, g_traffic String, e_tr String, g_tr String) row format delimited fields terminated by '\t' lines terminated by '\n' STORED AS TEXTFILE LOCATION '${OUTPUT}';

INSERT OVERWRITE TABLE email_traffic select se_value, count(distinct y_fingerprint) from email_input where event = 'page_view' and mkt_source = 'yotpo' and mkt_medium = 'email' group by se_value;

INSERT OVERWRITE TABLE general_traffic select se_value, count(distinct y_fingerprint) from email_input where event = 'page_view' group by se_value;

INSERT OVERWRITE TABLE email_tr select c1.se_value, count( c1.y_fingerprint) from email_input c1 JOIN email_input c2 on c1.y_fingerprint = c2.y_fingerprint and c1.se_value = c2.se_value and c1.app_id = 'tracking_code' and c2.mkt_source = 'yotpo' and c2.mkt_medium = 'email' group by c1.se_value;

INSERT OVERWRITE TABLE general_tr select c1.se_value, count(c1.y_fingerprint) from email_input c1 where c1.app_id = 'tracking_code'  group by c1.se_value;


INSERT OVERWRITE TABLE etotal select general_traffic.app_key, e_traffic, g_traffic, e_tr, g_tr from general_traffic left outer join email_traffic on email_traffic.app_key = general_traffic.app_key left outer join email_tr on general_traffic.app_key = email_tr.app_key left outer join general_tr on general_traffic.app_key = general_tr.app_key;