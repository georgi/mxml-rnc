/*
     Copyright 2008 Matthias Georgi. All rights reserved.

     ``The contents of this file are subject to the Mozilla Public License
     Version 1.1 (the "License"); you may not use this file except in
     compliance with the License. You may obtain a copy of the License at
     http://www.mozilla.org/MPL/

     Software distributed under the License is distributed on an "AS IS"
     basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
     License for the specific language governing rights and limitations
     under the License.

     The Original Code is xsd4mxml.

     The Initial Developer of the Original Code is Ali Mansuroglu.
     Portions created by the Initial Developer are Copyright (C) 2008
     Ali Mansuroglu. All Rights Reserved.

*/

package {
	import flash.utils.*;
	
	import mx.controls.Alert;
	import mx.core.*;
	
	public class Element {
		public var name : String;
		public var container : Boolean;
		public var attributes : Array = new Array();
		public var description : XML;
		public var classReference : Class;
		
		public function Element(name : String, attributes : Array = null) {
			this.name = name;
			
			addAttribute("implements", "text");
			
			if (attributes) {
				for each (var attr : String in attributes) {
					this.addAttribute(attr, "text");
				}
			}
		}
	
		public function readDefinition(className : String) : void {
			classReference = getDefinitionByName(className) as Class;
			description = describeType(classReference);
			container = (description..extendsClass.(@type == "mx.core::Container") != undefined);

			for each (var property : XML in description..accessor) {
				var propertyName : String = property.@name;					
				if(propertyName.charAt(0) != '$' && propertyName.charAt(0) != '_') {						
					if (property.@access != "readonly") {
						addAttribute(propertyName, xsdType(property.@type));							
					}
				}
			}
			
			for each (var variable : XML in description..variable) {					
				if(variable.@name.charAt(0) != '$' && variable.@name.charAt(0) != '_') {
					addAttribute(variable.@name, xsdType(variable.@type));
				}
			}			
			
			for each (var metadata : XML in description..metadata) {
				addMetadata(metadata);
			}
			
			addInheritedMetadata(classReference);
		}
		
		public function toString() : String {
			var result : String = "";
			
			result += "  " + name + " = element " + name + " {\n";
			
			if (container) {
				result += "    any*,\n";
			}
			
			result += attributes.join(",\n") + "\n";			
			result += "  }\n";
			
			return result;
		} 
		
		public function addAttribute(name : String, type : String) : void {
			attributes.push(new Attribute(name, type));
		}
		
		public static function xsdType(type : String) : String {
			switch (type) {
				case "Boolean": return "xsd:boolean";
				case "String": return "xsd:string";
				case "int":
				case "uint": return "xsd:decimal";
				case "Number": return "xsd:float";
			}
			return "text";				
		}
		
		public function addMetadata(metadata : XML) : void {
			if (metadata.@name == "Event" || metadata.@name == "Effect" || metadata.@name == "Style") {				
				var name : String = metadata.arg.(@key == "name").@value;
				var type : String = metadata.arg.(@key == "type").@value;
				var enum : String = metadata.arg.(@key == "enumeration").@value;
				
				if (enum) {
					var list : Array = [];
					for (var s : String in enum.split(',')) {
						list.push('"' + s + '"')
					}				
					addAttribute(name, list.join(' | '));
				}
				else {
					addAttribute(name, xsdType(type));							
				}
			}			
		}
		
		public function addInheritedMetadata(classReference : Class) : void {
			while(true) {
				var qualifiedSuperclassName : String = getQualifiedSuperclassName(classReference);
				
				if(qualifiedSuperclassName == null) {
					break;
				}
				
				classReference = getDefinitionByName(qualifiedSuperclassName) as Class;
				
				if(classReference == null) {
					break;
				}
				
				var description : XML = describeType(classReference);
				
				for each(var metadata : XML in description..metadata) {
					addMetadata(metadata);
				}
			}
		}
		
		public static function createComponentElements(components : XML) : Array {
			var result : Array = new Array();
			
			for each(var component : XML in components.component) {
				try {
					var element : Element = new Element(component.@name);
					element.readDefinition(component.@className); 
					result.push(element);
				}
				catch (error : Error) {
					trace(error);
					// Alert.show(error.message);
				}
			}
			
			return result;
		}

		public static function createDescription(components : XML) : String {
			var elements : Array = createComponentElements(components);
			
			var result : String = "";
			
			for each (var element : Element in elements) {
				result += String(element.description);
			}
			
			return result;
		}
		
		private static function createMxmlElements() : Array {
		    return [
		    	new Element("Binding", ["id", "source", "destination"]),
			    new Element("Component", ["id", "className"]),
			    new Element("Metadata", ["id"]),
			    new Element("Model", ["id", "source"]),
			    new Element("Script", ["id", "source"]),
			    new Element("Style", ["id", "source"]),
			    new Element("XML", ["id", "source", "format"]),
			    new Element("XMLList", ["id"])
		    ];
		}		
		
		public static function createSchema(components : XML) : String {
			var elements : Array = createComponentElements(components).concat(createMxmlElements());
			var names : Array = elements.map(function(e:Element, ...rest):String { return e.name; });
			var result : String = ""; 
			
			result += "default namespace = \"http://www.adobe.com/2006/mxml\"\n";
			result += "grammar {\n";
			result += elements.join("\n");
			result += "\n";			
			result += "  any = " + names.join("\n    |") + "\n";			
			result += "  start = Application\n";
			result += "}\n";
			
			return result;
		}
		
	}
}