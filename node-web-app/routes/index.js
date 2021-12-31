var express = require('express');
var router = express.Router();
const {RtcTokenBuilder, RtcRole} = require('agora-access-token');

router.get('/', function(req, res, next) {
  res.render('index', { title: 'myResponder Video Call Portal' });
});

router.get('/streaming', function(req, res, next) {
  res.render('streaming', { title: 'myResponder Video Call' });
});

router.get('/token', function(req, res, next) {
  // get channel name
  const channelName = req.query.channel;
  const uid = req.query.uid;
  if (!channelName) {
    return res.status(500).send('channel is required');
  } else if (!uid) {
    return res.status(500).send('uid is required');
  }
  // get role
  const role = RtcRole.PUBLISHER;
  // get the expire time
  const expireTime = 3600;
  // calculate privilege expire time
  const currentTime = Math.floor(Date.now() / 1000);
  const privilegeExpireTime = currentTime + expireTime;
  // build the token
  const token = RtcTokenBuilder.buildTokenWithUid('a991c309dd9b4466b7affb978e742b87', '062bd3840f4e4c48b65bfc27c90b24bc', channelName, uid, role);
  // return the token
  return res.send(token);
});

module.exports = router;