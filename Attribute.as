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
	
	public class Attribute {
		public var name : String;
		public var type : String;
		
		public function Attribute(name: String, type: String) {
			this.name = name;
			this.type = type;
		}
		
		public function toString() : String {
			return "    attribute " + name + " { " + type + " }?";	
		}
	}
	
}
