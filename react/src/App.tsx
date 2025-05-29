import React, { useState } from 'react';
import Onboarding from './components/Onboarding';
import RoomSelectScreen from './components/RoomSelectScreen';
import RoomCreateScreen from './components/RoomCreateScreen';
import MainScreen from './components/MainScreen';
import LoadingScreen from './components/LoadingScreen';
import WeeklyTimetableScreen from './components/WeeklyTimetableScreen';
import CalendarScreen from './components/CalendarScreen';
import ChatScreen from './components/ChatScreen';
import NotificationScreen from './components/NotificationScreen';
import SettingsScreen from './components/SettingsScreen';
import ProfileManageScreen from './components/ProfileManageScreen';
import RoomManageScreen from './components/RoomManageScreen';
import NoticeScreen from './components/NoticeScreen';

function App() {
  const [currentScreen, setCurrentScreen] = useState<
    'onboarding' | 'roomSelect' | 'roomCreate' | 'loading' | 'main' | 'timetable' | 'calendar' | 'chat' | 'settings' | 'notification' | 'profileManage' | 'roomManage' | 'notice'
  >('onboarding');

  const handleProfileComplete = () => setCurrentScreen('roomSelect');
  const handleCreateRoom = () => setCurrentScreen('roomCreate');
  const handleRoomCreateComplete = () => {
    setCurrentScreen('loading');
    setTimeout(() => setCurrentScreen('main'), 1500);
  };

  if (currentScreen === 'main')
    return <MainScreen setCurrentScreen={setCurrentScreen} />;
  if (currentScreen === 'loading') return <LoadingScreen />;
  if (currentScreen === 'roomCreate') return <RoomCreateScreen onComplete={handleRoomCreateComplete} />;
  if (currentScreen === 'roomSelect') return (
    <RoomSelectScreen
      onBack={() => setCurrentScreen('onboarding')}
      onCreate={handleCreateRoom}
    />
  );
  if (currentScreen === 'timetable')
    return <WeeklyTimetableScreen onBack={() => setCurrentScreen('main')} setCurrentScreen={setCurrentScreen} />;
  if (currentScreen === 'calendar') return <CalendarScreen onBack={() => setCurrentScreen('main')} setCurrentScreen={setCurrentScreen} />;
  if (currentScreen === 'chat') return <ChatScreen onBack={() => setCurrentScreen('main')} />;
  if (currentScreen === 'settings') return <SettingsScreen onBack={() => setCurrentScreen('main')} onProfileManage={() => setCurrentScreen('profileManage')} onRoomManage={() => setCurrentScreen('roomManage')} onNotice={() => setCurrentScreen('notice')} />;
  if (currentScreen === 'notification') return <NotificationScreen onBack={() => setCurrentScreen('main')} />;
  if (currentScreen === 'profileManage') return <ProfileManageScreen onBack={() => setCurrentScreen('settings')} />;
  if (currentScreen === 'roomManage') return <RoomManageScreen onBack={() => setCurrentScreen('settings')} />;
  if (currentScreen === 'notice') return <NoticeScreen onBack={() => setCurrentScreen('settings')} />;
  return <Onboarding onProfileComplete={handleProfileComplete} />;
}

export default App;
