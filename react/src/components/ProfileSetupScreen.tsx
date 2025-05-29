import React from 'react';

export default function ProfileSetupScreen({ onBack, onComplete }: { onBack?: () => void; onComplete?: () => void }) {
  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="relative max-w-[390px] min-h-[844px] w-full h-full bg-white shadow-2xl rounded-[24px] px-4 pt-12 pb-8 flex flex-col justify-start">
        {/* 뒤로가기 버튼 */}
        <button onClick={onBack} className="absolute top-6 left-4 text-[#191F28] text-2xl" aria-label="뒤로가기">←</button>
        <div className="w-full max-w-[340px] mx-auto flex flex-col">
          <div className="flex flex-col items-center justify-center mt-[96px] mb-8">
            <div className="text-[20px] font-bold text-[#191F28] text-center leading-relaxed mb-2">안녕하세요!<br />프로필을 만들어 주세요.</div>
          </div>
          <div className="mt-8 flex items-center justify-center relative">
            <div className="w-24 h-24 rounded-full bg-[#F2F4F6]" />
            <div className="absolute bottom-2 right-[calc(50%-48px)] bg-[#FA2E55] w-8 h-8 rounded-full flex items-center justify-center">
              <svg xmlns="http://www.w3.org/2000/svg" className="text-white w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 5c-.828 0-1.5.672-1.5 1.5S11.172 8 12 8s1.5-.672 1.5-1.5S12.828 5 12 5zM7 8V6H4v2H2v12h20V8H7zm10 9H7v-2h10v2zm0-4H7v-2h10v2z"/>
              </svg>
            </div>
          </div>
          <div className="mt-[24px] w-full flex flex-col gap-[16px]">
            <div className="text-sm text-[#8B95A1] font-normal">닉네임</div>
            <input
              className="w-full h-12 border border-[#D1D6DB] rounded-xl px-4 text-base text-[#191F28] placeholder-[#8B95A1] focus:outline-none focus:ring-2 focus:ring-[#FA2E55]"
              placeholder="룸메 동동 토마토"
            />
          </div>
          <button
            className="mt-[32px] w-full h-[52px] bg-[#FA2E55] text-white rounded-xl text-[16px] font-bold flex items-center justify-center gap-2 active:scale-95 mx-auto"
            onClick={onComplete}
          >
            완료
          </button>
        </div>
      </div>
    </div>
  );
}
