FROM ubuntu:trusty

RUN apt-get update && \
    apt-get install -y wget git python-setuptools python-dev libavcodec-dev libavformat-dev libswscale-dev libjpeg62 libjpeg62-dev libfreetype6 libfreetype6-dev apache2 libapache2-mod-wsgi mysql-server-5.5 mysql-client-5.5 libmysqlclient-dev gfortran python-pip php5-cgi libapache2-mod-php5 && \
    # the add-apt-repository command isn't included in ubuntu. we'll get it here.
    apt-get install -y software-properties-common python-software-properties && \
    add-apt-repository ppa:mc3man/trusty-media -y && \
    apt-get update && \
    apt-get install -y ffmpeg gstreamer0.10-ffmpeg

RUN sudo pip install SQLAlchemy==1.0.0 && \
    sudo pip install wsgilog==0.3 && \
    sudo pip install cython==0.20 && \
    sudo pip install mysql-python==1.2.5 && \
    sudo pip install munkres==1.0.7 && \
    sudo pip install parsedatetime==1.4 && \
    sudo pip install argparse && \
    sudo pip install numpy==1.9.2 && \
    sudo pip install Pillow


RUN cd /root && \
    git clone https://github.com/cvondrick/turkic.git && \
    git clone https://github.com/cvondrick/pyvision.git && \
    git clone https://github.com/cvondrick/vatic.git && \
    cd /root/turkic && \
    sudo python setup.py install && \
    cd /root/pyvision && \
    sudo python setup.py install


COPY config/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY config/apache2.conf /etc/apache2/apache2.conf

RUN sudo cp /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled && \
    sudo apache2ctl graceful

COPY config/config.py /root/vatic/config.py

RUN sudo /etc/init.d/mysql start && \
    cd /root/vatic && \
    mysql -u root --execute="CREATE DATABASE vatic;" && \
    turkic setup --database && \
    turkic setup --public-symlink

RUN sudo chown -R 755 /root/vatic/public && \
    find /root -type d -exec chmod 775 {} \; && \
    sudo chmod -R 775 /var/www && \
    apt-get install -y links && \
    apt-get install -y python-scipy && \
    sudo apache2ctl restart

# Debug tools
RUN apt-get install -y nano w3m man

COPY ascripts /root/vatic/ascripts
COPY scripts /root/vatic
# moved to the end to make troubleshooting quicker

# Prepare workspace for use
EXPOSE 80 443
# VOLUME ["/var/www", "/var/log/apache2", "/etc/apache2"]
# ENTRYPOINT ["/root/vatic/startup.sh"]
