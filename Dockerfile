FROM python:3.11
COPY . /opt/data
WORKDIR /opt/data
RUN ls -a
RUN apt-get update && apt-get install -y $(cat packages.txt)
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h
RUN apt-get update \
	&& curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
	&& curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
	&& apt-get update \
	&& ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools
RUN wget -O libpostal.tar.gz "https://github.com/openvenues/libpostal/archive/v1.1-alpha.tar.gz" \
    && mkdir -p /src  \
    && mkdir -p /data \
    && tar -xzf libpostal.tar.gz -C /src --strip-components=1 \
    && rm libpostal.tar.gz \
    && cd /src \
    && autoreconf -fi --warning=no-syntax --warning=no-portability \
    && ./configure --prefix=/usr --datadir=/data \
    && make -j "$(nproc)" \
    && make install \
    && rm -rf /src
RUN pip install postal
RUN pip install -r requirements.txt
