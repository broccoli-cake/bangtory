// backend/config/passport/googleStrategy.js

const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const { googleConfig } = require('../oauthConfig');

// 구글 OAuth 전략 등록
passport.use(new GoogleStrategy(
  {
    clientID: googleConfig.clientID,
    clientSecret: googleConfig.clientSecret,
    callbackURL: googleConfig.callbackURL,
    passReqToCallback:true
  },
  function(request, accessToken, refreshToken, profile, done) { 
	return done(null, profile); 
}
));
