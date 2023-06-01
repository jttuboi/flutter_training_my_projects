enum ResponseType {
  xUseDefinedInMethod(90000),
  x200ok(200),
  x201created(201),
  x202accepted(202),
  x401unautorized(401),
  x404notFound(404),
  ;

  const ResponseType(this.code);

  final int code;
}
