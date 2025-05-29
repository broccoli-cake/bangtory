import React from 'react';
import TomatoSnow from './TomatoSnow';

export default function LoadingScreen() {
  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="max-w-[390px] min-h-[844px] w-full h-full bg-white shadow-2xl rounded-[24px] flex flex-col items-center justify-center">
        <TomatoSnow />
        <div className="mt-8 text-[#FA2E55] text-xl font-bold animate-pulse">로딩 중...</div>
      </div>
    </div>
  );
} 