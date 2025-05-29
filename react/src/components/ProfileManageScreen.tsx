import React, { useState } from 'react';

export default function ProfileManageScreen({ onBack }: { onBack?: () => void }) {
  const [nickname, setNickname] = useState('룸메 동동 토마토 수하니');
  const [editMode, setEditMode] = useState(false);
  const [showLeaveModal, setShowLeaveModal] = useState(false);
  const [showExitModal, setShowExitModal] = useState(false);

  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="max-w-[390px] min-h-[844px] h-[844px] w-full bg-white shadow-2xl rounded-[24px] flex flex-col overflow-hidden relative">
        {/* 상단 헤더 */}
        <div className="flex items-center justify-between px-4 pt-6 pb-2 bg-white z-10 border-b border-[#F2F4F6]">
          <button onClick={onBack} className="text-[#191F28] text-2xl px-2" aria-label="뒤로가기">←</button>
          <div className="flex-1 text-center text-lg font-bold text-[#191F28]">프로필 관리</div>
          <div className="w-8" />
        </div>
        {/* 프로필 이미지 */}
        <div className="flex flex-col items-center mt-8 mb-6">
          <div className="relative">
            <div className="w-32 h-32 rounded-full bg-[#F2F4F6] flex items-center justify-center text-5xl text-[#D1D6DB]">{/* 프로필 이미지 자리 */}</div>
            <button className="absolute bottom-2 right-2 w-9 h-9 rounded-full bg-[#FA2E55] flex items-center justify-center text-white border-4 border-white shadow">
              <span className="material-icons">photo_camera</span>
            </button>
          </div>
        </div>
        {/* 닉네임 입력 */}
        <div className="px-8 mb-6">
          <div className="text-xs text-[#8B95A1] mb-1">닉네임</div>
          <div className="flex items-center gap-2">
            <input
              className="flex-1 h-12 rounded-xl border border-[#E5E8EB] bg-white px-4 text-base text-[#191F28] focus:outline-none focus:border-[#FA2E55]"
              value={nickname}
              onChange={e => setNickname(e.target.value)}
              disabled={!editMode}
            />
            <button onClick={() => setEditMode(e => !e)} className="text-[#8B95A1]">
              <span className="material-icons text-xl">{editMode ? 'check' : 'edit'}</span>
            </button>
          </div>
        </div>
        {/* 완료 버튼 */}
        <div className="px-8 mb-8">
          <button className="w-full h-12 bg-[#FA2E55] text-white rounded-xl text-[18px] font-bold flex items-center justify-center gap-2 active:scale-95 transition">완료</button>
        </div>
        {/* 하단 버튼 */}
        <div className="flex justify-center items-center gap-0 border-t border-[#F2F4F6]">
          <button className="flex-1 py-6 text-[#8B95A1] font-bold border-r border-[#F2F4F6]" onClick={() => setShowLeaveModal(true)}>방 나가기</button>
          <button className="flex-1 py-6 text-[#8B95A1] font-bold" onClick={() => setShowExitModal(true)}>탈퇴하기</button>
        </div>
        {/* 방 나가기 모달 */}
        {showLeaveModal && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/20 z-20">
            <div className="bg-white rounded-2xl p-6 w-80 max-w-[90vw] flex flex-col items-center shadow-xl">
              <span className="material-icons text-4xl text-[#FA2E55] mb-2">warning_amber</span>
              <div className="text-lg font-bold text-[#FA2E55] mb-1">방 나가기</div>
              <div className="text-sm text-[#191F28] mb-6">이 방을 정말 나가시겠습니까?</div>
              <div className="flex gap-3 w-full">
                <button className="flex-1 h-10 rounded-xl border border-[#E5E8EB] bg-white text-[#191F28] text-sm font-bold" onClick={() => setShowLeaveModal(false)}>취소</button>
                <button className="flex-1 h-10 rounded-xl bg-[#FA2E55] text-white text-sm font-bold" onClick={() => { setShowLeaveModal(false); /* 실제 방 나가기 처리 */ }}>나가기</button>
              </div>
            </div>
          </div>
        )}
        {/* 탈퇴하기 모달 */}
        {showExitModal && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/20 z-20">
            <div className="bg-white rounded-2xl p-6 w-80 max-w-[90vw] flex flex-col items-center shadow-xl">
              <span className="material-icons text-4xl text-[#FA2E55] mb-2">warning_amber</span>
              <div className="text-lg font-bold text-[#FA2E55] mb-1">탈퇴하기</div>
              <div className="text-sm text-[#191F28] mb-6">정말 탈퇴하시겠습니까?</div>
              <div className="flex gap-3 w-full">
                <button className="flex-1 h-10 rounded-xl border border-[#E5E8EB] bg-white text-[#191F28] text-sm font-bold" onClick={() => setShowExitModal(false)}>취소</button>
                <button className="flex-1 h-10 rounded-xl bg-[#FA2E55] text-white text-sm font-bold" onClick={() => { setShowExitModal(false); /* 실제 탈퇴 처리 */ }}>탈퇴하기</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
} 