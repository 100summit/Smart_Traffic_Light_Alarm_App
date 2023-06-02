class Con2 {
  int? gTime;
  int? rTime;
  String? state;
  String? time;

  Con2({this.gTime, this.rTime, this.state, this.time});

  Con2.fromJson(Map<String, dynamic> json) {
    gTime = json['g_time'];
    rTime = json['r_time'];
    state = json['state'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['g_time'] = gTime;
    data['r_time'] = rTime;
    data['state'] = state;
    data['time'] = time;
    return data;
  }
}
