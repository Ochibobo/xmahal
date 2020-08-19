import 'package:meta/meta.dart';
import 'xmodel.dart';
import 'xml_creator.dart';

/*
  Class for  Dart <--> XML conversion
  This is just a method specification for classes implementing XMahal
*/
abstract class XMahal {
  XMahal();

  //Used to map XML documents to Dart Objects
  XMahal fromXMLElements({@required XElement element}) {
    return null;
  }

  //Convert Dart object to XML object
  String toXMLString() {
    return '';
  }

  //Create an XNode instance of this class
  XNode getClassNode() {
    return null;
  }
}
