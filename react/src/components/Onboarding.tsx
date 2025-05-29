import React, { useEffect, useState } from 'react';
import OnboardingScreen, { Tomato } from './OnboardingScreen';
import LoginScreen from './LoginScreen';
import ProfileSetupScreen from './ProfileSetupScreen';
import MainScreen from './MainScreen';

export default function Onboarding({ onProfileComplete }: { onProfileComplete: () => void }) {
  const [showLogin, setShowLogin] = useState(false);
  const [showProfile, setShowProfile] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => setShowLogin(true), 2000);
    return () => clearTimeout(timer);
  }, []);

  const handleAnyClick = () => {
    setShowProfile(true);
  };

  const handleBack = () => {
    setShowProfile(false);
  };

  const handleProfileComplete = () => {
    onProfileComplete();
  };

  if (showProfile) return <ProfileSetupScreen onBack={handleBack} onComplete={handleProfileComplete} />;
  if (showLogin) return <div onClick={handleAnyClick}><LoginScreen Tomato={Tomato} /></div>;
  return <div onClick={handleAnyClick}><OnboardingScreen /></div>;
} 