class NullTargetNodeException implements Exception {
  final String msg;
  const NullTargetNodeException(this.msg);
  String toString() => "NullTargetNodeException: $msg";
}
