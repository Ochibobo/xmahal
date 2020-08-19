class NullTargetNodeException implements Exception {
  final String msg;
  const NullTargetNodeException(this.msg);
  @override
  String toString() => 'NullTargetNodeException: $msg';
}
