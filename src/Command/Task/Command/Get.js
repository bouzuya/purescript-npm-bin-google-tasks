// https://developers.google.com/tasks/v1/reference/tasks/get
exports.getTaskImpl = function (options) {
  return function (client) {
    return function () {
      const google = require('googleapis').google;

      const tasks = google.tasks({ version: 'v1', auth: client });
      return new Promise(function (resolve, reject) {
        tasks.tasks.get(options, function (error, result) {
          if (error)
            reject(error);
          else
            resolve(result);
        });
      });
    };
  };
};
