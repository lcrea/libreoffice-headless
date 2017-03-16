# LibreOffice headless mode Docker image

This image is designed to be used in conjunction with [OpenERP v6.1 & AerooLib](https://hub.docker.com/r/lcrea/odoo/), but it can work with any other project that requires an installation of LibreOffice in headless mode.

**What is "headless mode"?**  
 Headless mode is *a special mode which allows using LibreOffice without user interface and controlling it by external clients via the APIs*.


## How to use it
No images are required to run this one, but, if you want to use it along with OpenERP v6.1 & AerooLib (that's my original project), then these images are necessary:

-   PostgreSQL
-   [lcrea/odoo:6.1](https://hub.docker.com/r/lcrea/odoo/)

### Start Libreoffice
`$ docker run -d --name oe_loffice lcrea/libreoffice-headless`

### Start PostgreSQL (optional)
```
$ docker run -d \
    -e POSTGRES_USER=openerp \
    -e POSTGRES_PASSWORD=openerp \
    --name oe_db \
    postgres:9-alpine
```

### Start OpenERP (optional)
```
$ docker run -d \
    -e DB_NAME=openerp \
    -e DB_PWD=openerp \
    -e DB_USER=openerp \
    --link oe_db:psql \
    --link oe_loffice:libreoffice \
    -p 8069:8069 \
    --name openerp \
    lcrea/odoo:6.1
```


## Custom configuration

### Port available
The native port is exposed:
-   `8100`

### External volumes
This volume is declared:
-   `/usr/local/share/fonts/`: to mount your fonts folder.

#### How to add extra fonts
You can mount a folder from the filesystem full of fonts with the `-v` Docker parameter, like this:

```
$ docker run -d \
    -v /path/to/your/fonts/:/usr/local/share/fonts \
    --name oe_loffice \
    lcrea/libreoffice-headless
```

Alternatively, you can build another image based on this one with all the fonts inside it, or:

1.  Create a Docker volume.
1.  Copy all the fonts inside it.
1.  Mount the volume just created to the `/usr/local/share/fonts/` path.

##### Fonts check
If you want to verify that all your extra fonts are loaded correctly, you can simply use the `fc-list` command, like this:

```
$ docker run \
    -v /path/to/your/fonts/:/usr/local/share/fonts \
    --name oe_loffice \
    lcrea/libreoffice-headless \
    fc-list
```

The `fc-list` function will print out on the standard output a full list of all the fonts recognized by LibreOffice.

### Environment variables
Even if the default values are the most suggested, if necessary, it's possible to customize their behavior through these variables:

-   `HOST_IN`: the hostname or IP of the external client accepted as input.
    -   default: `0` (**any external hosts**)
-   `PORT_IN`: the listening port used by external clients to connect to the container.
    -   default: `8100`
-   `LANG`: it enables the UTF-8 locale coding in the internal filesystem of the container.
    -   default: `C.UTF-8` (**highly suggested**)

#### What the `LANG` variable is about?
This image is based on Debian Jessie and, as reported on the official page, this is a "minbase" version of Debian and, because of that, it uses a ASCII locale coding as default.  
Any other locale must be enabled through the `LANG` variable or, eventually, installed/generated through the local package.

If you need to handle accented (non english) filename or any other special char that require UTF-8 coding, leave the default value `C.UTF-8`: it should be the best for most of the cases.

For more information about it, please consult the Official Debian page at this link, at the chapter "Locales": [https://hub.docker.com/_/debian/](https://hub.docker.com/_/debian/)


## Docker Compose example with OpenERP v6.1 & Aeroolib
What's following is only an example of a simple (but fully working) OpenERP v6.1 environment.

```yaml
version: '2'

services:
    libreoffice:
        image: lcrea/libreoffice-headless

    psql:
        image: postgres:9-alpine
        environment:
            - POSTGRES_PASSWORD=${PSQL_PASS}
            - POSTGRES_USER=${PSQL_USER}

    openerp:
        image: lcrea/openerp:6.1
        depends_on:
            - libreoffice
            - psql
        environment:
            - DB_NAME=${PSQL_DB}
            - DB_PWD=${PSQL_PASS}
            - DB_USER=${PSQL_USER}
        links:
            - libreoffice:libreoffice
            - psql:psql
        ports:
            - "8069:8069"
        volumes:
            - /path/to/your/modules/:/mnt/extra-addons
```

### Note
I intentionally wanted to show an example of a Docker Compose file with environment values stored in an external `.env` file, as described in the official Docker documentation. If you don't want to use this feature, **simply substitute any `${ }` variable with their values**.

#### Debug
If you want to pass environment values to the image through the `.env` file, I included a simple `debug` function that prints out on the standard output all of them.  
This should help you to check if your configuration is running as you expect.

```
$ docker run \
    -v /path/to/your/fonts/:/usr/local/share/fonts \
    -e HOST_IN=${MY_HOST} \
    -e PORT_IN=${MY_PORT} \
    --name oe_loffice \
    lcrea/libreoffice-headless \
    debug
```


## Known issue
When the LibreOffice container is stopped, it exits with this non-zero status code:
-   `Exited (255)`

That's because LibreOffice seems to not have a clean shutdown process in demon mode (maybe because the project itself is not mainly thought to work in headless mode, but through the GUI).

Anyway, when the container will be restarted, everything will start fine too.  
So, **it's just a formal fault** that not influence its behavior at all.


## Update plan
I've scheduled an automatic monthly rebuild of the image (on the **1st of every month**, to be precise) to guarantee a regular update of the Debian image and of LibreOffice.  
This update plan is intentionally lined up with the one of my image [OpenERP v6.1 & AerooLib](https://hub.docker.com/r/lcrea/odoo/) to keep both of them synced.


## Support
If you have any issues, please report them to:  
[https://github.com/lcrea/libreoffice-headless/issues](https://github.com/lcrea/libreoffice-headless/issues).  

If you made any improvements, please open a pull request to:  
[https://github.com/lcrea/libreoffice-headless/pulls](https://github.com/lcrea/libreoffice-headless/pulls).


## License
All the files of this image are available on my GitHub repo [https://github.com/lcrea/libreoffice-headless](https://github.com/lcrea/libreoffice-headless) under the [MIT license](https://github.com/lcrea/libreoffice-headless/blob/master/LICENSE).


## Author
Luca Crea  
[https://www.linkedin.com/in/lucacrea](https://www.linkedin.com/in/lucacrea)
