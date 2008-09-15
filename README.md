Relax NG Schema Creator for Adobe Flex 3
========================================

This Flex application allows you to generate an Relax NG compact
schema by extracting the needed information by reflection at runtime.

The application reads the classes found in `mxml-manifest.xml` and
asks the Flash VM about attributes, events and styles a Flex component
class provides.

## Build

* Install FLEX 3 SDK and Ant.

* Configure the location of the SDK in the build.properties file.

* Run Ant: `ant`


## Running the Creator

Just start SchemaCreator.swf, on a Windows System you can doubleclick
the file, on a Linux System you can do this:

    flashplayer SchemaCreator.swf


## Credits

The original [XSD Schema creator][1] was developed by Ali Mansuroglu
<mansurogluali@gmail.com>.

[1]: http://code.google.com/p/xsd4mxml/
