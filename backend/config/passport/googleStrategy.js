// backend/config/passport/googleStrategy.js

const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth2').Strategy;
const { googleConfig } = require('../oauthConfig');

passport.serializeUser((user , done) => { 
	done(null , user); 
}) 
passport.deserializeUser(function(user, done) { 
	done(null, user); 
}); 

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
