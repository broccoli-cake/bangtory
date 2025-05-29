import React from 'react';

export default function RoomSelectScreen({ onBack, onCreate }: { onBack?: () => void, onCreate?: () => void }) {
  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="relative max-w-[390px] min-h-[844px] w-full h-full bg-white shadow-2xl rounded-[24px] px-4 pt-12 pb-8 flex flex-col">
        {/* 뒤로가기 버튼 */}
        <button onClick={onBack} className="absolute top-6 left-4 text-[#191F28] text-2xl" aria-label="뒤로가기">←</button>
        <div className="flex-1 flex flex-col justify-center items-center w-full">
          <div className="flex flex-col gap-[16px] w-full max-w-[340px]">
            <button onClick={onCreate} className="w-full bg-white rounded-xl border-2 border-transparent hover:border-[#FA2E55] shadow-sm py-8 flex flex-col items-center transition active:scale-95">
              <span className="text-[#FA2E55] text-3xl mb-2">＋</span>
              <span className="text-[#191F28] text-base font-medium">방 만들기</span>
            </button>
            <button className="w-full bg-white rounded-xl border-2 border-transparent hover:border-[#FA2E55] shadow-sm py-8 flex flex-col items-center transition active:scale-95">
              <span className="mb-2">
                <svg width="24" height="24" viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M8 6C8 4.89543 8.89543 4 10 4H26C27.1046 4 28 4.89543 28 6V30C28 31.1046 27.1046 32 26 32H10C8.89543 32 8 31.1046 8 30V6Z" stroke="#FA2E55" strokeWidth="2.5" fill="#FA2E55" fillOpacity="0.1"/>
                  <rect x="16" y="18" width="4" height="6" rx="2" fill="#FA2E55"/>
                  <rect x="20" y="14" width="2" height="2" rx="1" fill="#FA2E55"/>
                </svg>
              </span>
              <span className="text-[#191F28] text-base font-medium">방 들어가기</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
} 