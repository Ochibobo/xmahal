import 'package:meta/meta.dart';

//A class used to create XML Elements(Convert Dart object to XMLString)
class XMLCreator {
  //The default content is xml with version 1.0
  String _content;
  num _version;
  /*
    StringBuffer is used to store the final XML String,
    It is preferred to the regular String due to its excellent append nature
  */
  final StringBuffer _xmlStringBuffer = StringBuffer();

  XMLCreator()
      : _content = 'xml',
        _version = 1.0;
  //Set the document type
  void setType({String docType, num version}) {
    _content = docType;
    _version = version;
  }

  //Create xml document and return it as a string
  String createXML({@required XNode xnode}) {
    _xmlStringBuffer.write(_getHeader());
    _traverse(xnode: xnode);
    return _xmlStringBuffer.toString();
  }

  //Get the header content
  String _getHeader() => '<?$_content version=\"$_version\"?>';

  //Traverse the parent node
  void _traverse({@required XNode xnode}) {
    if (xnode == null) return null;
    !xnode.isSelfClosing
        ? _xmlStringBuffer.write(xnode.attributes != null
            ? '<${xnode.tagName} ${_formatAttributes(xnode.attributes)}>'
            : '<${xnode.tagName}>')
        : _xmlStringBuffer.write(
            "<${xnode.tagName} ${xnode.attributes != null ? _formatAttributes(xnode.attributes) : ""}/>");
    if (xnode.text != null) _xmlStringBuffer.write('${xnode.text}');

    if (xnode.children != null) {
      for (var node in xnode.children) {
        _traverse(xnode: node);
      }
    }
    if (!xnode.isSelfClosing) _xmlStringBuffer.write('</${xnode.tagName}>');
  }

  String _formatAttributes(Map<String, dynamic> attributes) {
    var _attributes = '';
    attributes.forEach((k, v) => _attributes += '$k=\"$v\" ');
    //Trim right to remove the right-most space
    return _attributes.trimRight();
  }
}

class XNode {
  //Map to specify node attributes
  Map<String, dynamic> _attributes;
  //Text associated with the node
  String _text;
  /* 
    Boolean to specify if the XML Node definition is self closing
    If true, instead of specifying, eg,  <person> <name> Smith </name> </person>, 
    it creates <person name="Smith" />
  */
  bool isSelfClosing;
  //A list to store nodes, specifically child nodes
  List<XNode> _xNodes = [];
  //The XmlTag name
  String tagName;

  /*
    Creating an instance of the XNode
    The tagName is compulsory, the default is isNotSelfClosing
  */
  XNode(
      {@required this.tagName,
      this.isSelfClosing = false,
      String text,
      Map<String, dynamic> attributes})
      : _text = text,
        _attributes = attributes;

  //Set the node's attributes
  void setAttributes({@required Map<String, dynamic> attributes}) =>
      _attributes = attributes;

  //Set the node's text
  void setText({@required String text}) => _text = text;

  //Get the attributes of the node
  Map<String, dynamic> get attributes => _attributes;

  //Get the text of the node
  String get text => _text;

  //Add a single child node
  void addNode({@required XNode node}) => _xNodes.add(node);

  //Add a list of children nodes
  void addNodes({@required List<XNode> nodes}) =>
      nodes.forEach((node) => _xNodes.add(node));

  //Return children of the given node
  List<XNode> get children => _xNodes;
}
