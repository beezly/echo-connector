echo-connector
==============

Ruby API to echo360

Installation 
------------

You need Ruby and rubygems installed. Once you have those;

    gem install echo-connector

Usage
-----

At the moment the library only supports login, get and create users.

Example
-------

    echo = Echo360::Echo360.new 'https://echo.server:8443', <consumer key>, <consumer_secret>
    users = echo.get_users
    echo.create_user 'fsmith', 'p&55w0rd', 'Fred', 'Smith', 'role-name-academic-staff', 'fsmith@institution.ac.uk'


