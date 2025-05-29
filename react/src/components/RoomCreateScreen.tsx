import React from 'react';

export default function RoomCreateScreen({ onBack, onComplete }: { onBack?: () => void, onComplete: () => void }) {
  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="relative max-w-[390px] min-h-[844px] w-full h-full bg-white shadow-2xl rounded-[24px] px-4 pt-12 pb-8 flex flex-col justify-start">
        {/* 뒤로가기 버튼 */}
        <button onClick={onBack} className="absolute top-6 left-4 text-[#191F28] text-2xl" aria-label="뒤로가기">←</button>
        <div className="w-full max-w-[340px] mx-auto flex flex-col">
          <div className="text-[24px] font-bold text-[#191F28] mt-[96px] mb-8 text-left">방 이름을 정해주세요.</div>
          <div className="mb-4 mt-[24px]">
            <label className="block text-sm text-[#8B95A1] mb-2 font-normal">방 이름</label>
            <input className="w-full h-12 border border-[#D1D6DB] rounded-xl px-4 text-base text-[#191F28] placeholder-[#8B95A1] focus:outline-none focus:ring-2 focus:ring-[#FA2E55]" placeholder="" />
          </div>
          <div className="mb-8 mt-[24px]">
            <label className="block text-sm text-[#8B95A1] mb-2 font-normal">주소</label>
            <input className="w-full h-12 border border-[#D1D6DB] rounded-xl px-4 text-base text-[#191F28] bg-[#F9FAFB] placeholder-[#8B95A1] focus:outline-none focus:ring-2 focus:ring-[#FA2E55]" placeholder="예: 판교대로 235, 분당 주소, 성남동 681" />
          </div>
          <button type="submit" className="w-full h-[52px] bg-[#FA2E55] text-white rounded-xl text-[16px] font-bold flex items-center justify-center gap-2 mt-[32px] active:scale-95" onClick={onComplete}>
            방 만들기 <span className="text-xl">🍅</span>
          </button>
        </div>
      </div>
    </div>
  );
} 