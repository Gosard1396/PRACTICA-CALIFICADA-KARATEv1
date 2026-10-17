function fn() {
    var config = {
        host: 'http://134.209.211.10'
    };
    karate.configure('headers', { 'x-channel': 'WEB' });
    karate.configure('connectTimeout', 10000);
    karate.configure('readTimeout', 10000);
    return config;
}