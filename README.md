> **If you use the resources (algorithm, code and dataset) presented in this repository, please cite our paper.**  
*The BibTeX entry is provided at the bottom of this page. 

# UTE: A Ubiquitous Data Exploration Platform for Mobile Sensing Experiments
Ubiquitous data Exploration (UTE) is a mobile sensor data collection, annotation and exploration platform. Our platform facilitates rapid prototyping of data mining experiments by using a flexible and do-it-yourself approach. The platform allows researchers to quickly design and deploy applications on mobile devices in order to record sensor data and the corresponding ground-truth information. The platform is supported by a web interface for designing data collection experiments, synchronizing and storing the sensor data with the corresponding labels, and sharing data.

This repository is dedicated to Cloud-UTE, the backend-app component of UTE platform. 

> **For iOS client, please refer to this repository: [Mobi-UTE iOS](https://github.com/cruiseresearchgroup/mobiute-ios).**  
**For Android client, please refer to this repository: [Mobi-UTE Android](https://github.com/cruiseresearchgroup/mobiute-android).** 

Please refer to our following paper for the details of UTE: http://ieeexplore.ieee.org/document/7517818/ 

* Ruby version: 2.5

* Deployment instructions

Initial seed command to mongodb: 
```terminal
rake db:seed
```

```terminal
rails runner 'Delayed::Backend::Mongoid::Job.create_indexes'
```

Running unicorn web server: 
```terminal
bundle exec unicorn -p 8080 -c ./config/unicorn.rb
```

Running background service - async process (delayed job): 
```terminal
bin/delayed_job start 
```

To turn off async process (delayed job), do the following:
```terminal
#bin/delayed_job stop
```

Default username and password for admin portal: 
```
username: admin
password: admin
```

# Citation
When citing UTE in academic papers and theses, please use this BibTeX entry:
```
@INPROCEEDINGS{7517818, 
author={J. Liono and T. Nguyen and P. P. Jayaraman and F. D. Salim}, 
booktitle={2016 17th IEEE International Conference on Mobile Data Management (MDM)}, 
title={UTE: A Ubiquitous Data Exploration Platform for Mobile Sensing Experiments}, 
year={2016}, 
volume={1}, 
number={}, 
pages={349-352}, 
keywords={Internet;data mining;mobile computing;software prototyping;user interfaces;UTE platform;Web interface;data mining;mobile device;mobile sensing;rapid prototyping;ubiquitous data exploration;Data collection;Data mining;Labeling;Mobile communication;Mobile handsets;Performance evaluation;Sensors}, 
doi={10.1109/MDM.2016.61}, 
ISSN={}, 
month={June},}
```
