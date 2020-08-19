import 'xml_exceptions.dart';
import 'package:xpath/xpath.dart';
import 'package:meta/meta.dart';
import 'xmahal.dart';

//This mixin is used to help create a class from a class
mixin CreateAlias {}

//Create a type using mixins
class XElem<T extends Element> {
  T value;
  static XModel _xModel;
  XElem(this.value);

  /*
    Used to create a new instance of XModel
    However, for consistency purposes, an instance of XModel is created 
    from XElement, the base object used for reading XML objects
  */
  static XElement asXElement({
    @required xmlDoc,
    @required parentTag,
  }) {
    //Pass the xmlDoc and the parent tag
    _xModel = XModel(xmlDoc: xmlDoc, parentTag: parentTag);
    //Should the object return null, stop executon and return null
    if (_xModel == null) {
      throw NullTargetNodeException(
          "Could not find parent node. Either xmlDoc was empty or $parentTag could not be found");
    }
    /*
     If the parent node is not exxisting -> since the tag specified does not exist,
     stop execution and return null
    */
    if (_xModel.getParentNode == null) {
      throw NullTargetNodeException(
          'Parser could not resolve parentTag: $parentTag from XML Doc');
    }

    //Return the element as an instance of XElement
    final Element parentNode = _xModel.getParentNode[0];
    return XElement(parentNode);
  }

  //To retrieve text from an element
  String getTextFromElement({String tagName = ""}) {
    /* 
      If the tag name is specified, get text from that tagName
      else get the text from the current value
    */
    var target = tagName.isNotEmpty
        ? value.xpath("/$tagName/text()")
        : value.xpath("/text()");

    //Should the node be null or none existent, stop execution and return null
    if (target == null) {
      throw NullTargetNodeException(
          "Parser could not resolve tagName: $tagName from parent node while trying to retrieve text");
    }
    //Alternatively, return the text value of the given node
    return target[0].name;
  }

  //Used to map an entire XML Element to a Dart Class which must be an instance of XMahal
  V getElement<V extends XMahal>({V instance, @required String path}) {
    /* 
      Path is necessary to specify here. This method is mostly used to 
      map XML to a Dart object that is nested within another object or whose
      XMLDoc is a child within the current XMLDoc being traversed 
    */
    var target = value.xpath("$path");
    /*
      Stop execution and return null if the element does not exist probably due to 
      invalid tag name
    */
    if (target == null) {
      throw NullTargetNodeException(
          "Parser could not resolve tagName: $path from parent node while trying to retrieve element");
    }
    //If the Element exists, convert it to an XElement
    XElement xElement = XElement(target[0]);
    //Retrun a new instance of the class from the XElement
    return instance.fromXMLElements(element: xElement);
  }

  //Retrieve the attributes of a given XMLElement
  Map<String, dynamic> getAttributeMap({String tagName = ""}) {
    /* 
      Using the tagName, fetch the node
      If the tagName is empty, use the current node
      */

    var target = tagName.isEmpty
        ? value
        : value.xpath("/$tagName") == null ? null : value.xpath("/$tagName")[0];
    //If the target is null, stop execution and return null
    if (target == null) {
      throw NullTargetNodeException(
          "Parser could not resolve tagName: $tagName from parent node while trying to retrieve attributes");
    }
    //Return the map of attributes
    return target.attributes;
  }

  //Retrieve as list of Objects
  List<E> getList<E extends XMahal>({
    @required E instance,
    String tagName = "",
  }) {
    //Get the instanc of the parent node
    List<Element> parentNode = _xModel.getParentNode;
    List<Element> target =
        tagName.isEmpty ? parentNode : parentNode[0].xpath("/$tagName");
    //Stop execution and return null if the target Node does not exist
    if (target == null) {
      throw NullTargetNodeException(
          "Parser could not resolve tagName: $tagName from parent node while trying to retrieve list of element");
    }

    //The List to store Dart objects retrieved from the XMLDoc
    List<E> elements = [];

    target.forEach((f) {
      //Map each XMLElement to the specified Dart object and add it to the list of Dart objects
      XElement value = XElement(f);
      elements.add(instance.fromXMLElements(element: value));
    });

    //Return the List of Dart objects
    return elements;
  }
}

//Create an instance of XElement
class XElement = XElem<Element> with CreateAlias;

class XModel {
  final String xmlDoc;
  final String parentTag;
  ETree _tree;
  //Regex to remove the <?xml version = k ?> from the string prior to parsing it
  //The second quantifier is for lazy loading (though not necessary for this context)
  final RegExp _regExp = RegExp(r"\<?.*?\?>");
  List<Element> parentNode;

  //Constructor to initialize the XML Doc and the parent node
  XModel({
    @required this.xmlDoc,
    @required this.parentTag,
  }) {
    //Remove the top <?xml version = k ?> before parsing
    String _parsableDoc = xmlDoc.replaceAll(_regExp, "");
    _tree = ETree.fromString(_parsableDoc);
    parentNode = _tree.xpath("/$parentTag");
  }

  List<Element> get getParentNode => parentNode;
  //Set/Change the parent node
  void setParentNode(String tag) => this.parentNode = _tree.xpath("/$tag");

  //Retrieve text from an XML Node
  @deprecated(
      reason:
          "This method has been replaced by getTextFromElement in XElem class." +
              "However, it is still usable.")
  dynamic getTextFromNode({String tagName = ""}) {
    List<Element> target = tagName.isEmpty
        ? this.parentNode[0].xpath("/text()")
        : this.parentNode[0].xpath("/$tagName/text()");
    if (target == null) {
      throw NullTargetNodeException(
          "Parser could not resolve tagName: $tagName from parent node while trying to retrieve text");
    }
    return target[0].name;
  }

  //Retrieve attributes from an XML Node
  @deprecated(
      reason:
          "This method has been replaced by getAttributeMap in XElem class." +
              "However, it is still usable.")
  Map<String, dynamic> getAttributesFromNode({String tagName = ""}) {
    List<Element> target = tagName.isEmpty
        ? this.parentNode
        : this.parentNode[0].xpath("/$tagName");
    if (target == null) {
      throw NullTargetNodeException(
          "Parser could not resolve tagName: $tagName from parent node while trying to retrieve attributes");
    }
    return target[0].attributes;
  }

  //Retrieve as list of Objects
  @deprecated(
      reason:
          "This method has been replaced by getAttributeMap in XElem class." +
              "However, it is still usable.")
  List<T> getList<T extends XMahal>({
    @required T instance,
    String tagName = "",
  }) {
    List<Element> target =
        tagName.isEmpty ? parentNode : parentNode[0].xpath("/$tagName");
    if (target == null) {
      throw NullTargetNodeException(
          "Parser could not resolve tagName: $tagName from parent node.");
    }

    List<T> elements = [];
    target.forEach((f) {
      XElement value = XElement(f);
      elements.add(instance.fromXMLElements(element: value));
    });

    return elements;
  }
}

class XMLTable {
  //A List to hold table head details
  List<String> _tableHeaders = [];

  //Create an instance of XElement that will be used to retrieve table elements
  XElement xELement;

  //Initialize the class instance with
  XMLTable({@required this.xELement});

  //Get the table headers
  //Path may be in the form /TR
  List<String> getTableHeaders({String tagName}) {
    List<Element> _parentNode = _getParentNode(tagName: tagName);

    _parentNode.forEach(
        (header) => _tableHeaders.add(_getTextFromElement(element: header)));

    return _tableHeaders;
  }

  //Get the parent node
  List<Element> _getParentNode({String tagName}) {
    return tagName == null
        ? xELement.value.xpath("")
        : xELement.value.xpath("/$tagName");
  }

  //Get text from table tags
  String _getTextFromElement({Element element}) {
    return element.xpath("/text()")[0].name;
  }

  //Create an instance of List<Map<String,dynamic>> to rep a table
  List<Map<String, dynamic>> getDataFrame(
      {@required String headerTag, String dataTag = "/TD"}) {
    List<Map<String, dynamic>> _dataFrame = [];
    //Get the headers first
    List<String> _headers = getTableHeaders(tagName: headerTag);
    //The data rows
    List<Element> _dataRows = xELement.value.children.sublist(1);
    //Create a Map to hold row key-value pairs
    Map<String, dynamic> _row = {};
    //Loop through each data row and create a map of values
    _dataRows.forEach((f) {
      int i = 0;
      //Loop through row values adding them to the data framw
      f.xpath(dataTag).forEach((f) {
        //Add the data with its header as {header : data}
        //Header data is the column head
        //Since headers were already fetched, loop through them depending on the value
        //and the number of values present
        _row[_headers[i]] = _getTextFromElement(element: f);
        i++;
      });
      //Add the Map to the list
      //Adding it as a new map does not override existing values
      _dataFrame.add(Map.from(_row));
    });
    //Return a data frame containing the rows with headers as a list of Maps
    return _dataFrame;
  }
}

/*
  Class used to generate the deprecated annotation used only for information purposes
  and has no impact whatsoever in the execution of the program
*/
class deprecated {
  final String reason;
  const deprecated({this.reason});
}
