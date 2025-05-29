import React, { useState } from 'react';

export default function SettingsScreen({ onBack, onProfileManage, onRoomManage, onNotice }: { onBack?: () => void, onProfileManage?: () => void, onRoomManage?: () => void, onNotice?: () => void }) {
  const [pushEnabled, setPushEnabled] = useState(true);
  const [showLogoutModal, setShowLogoutModal] = useState(false);

  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="max-w-[390px] min-h-[844px] h-[844px] w-full bg-white shadow-2xl rounded-[24px] flex flex-col overflow-hidden relative">
        {/* 상단 헤더 */}
        <div className="flex items-center justify-between px-4 pt-6 pb-2 bg-white z-10">
          <button onClick={onBack} className="text-[#191F28] text-2xl px-2" aria-label="뒤로가기">←</button>
          <div className="flex-1 text-center text-lg font-bold text-[#191F28]">설정</div>
          <div className="w-8" />
        </div>
        {/* 설정 리스트 */}
        <div className="flex-1 px-4 py-4">
          <div className="bg-[#F9FAFB] rounded-xl overflow-hidden border border-[#F2F4F6] divide-y divide-[#F2F4F6]">
            <button className="w-full flex items-center justify-between px-4 py-4 text-sm text-[#191F28] font-medium" onClick={onProfileManage}>
              프로필 관리
              <span className="material-icons text-base text-[#8B95A1]">chevron_right</span>
            </button>
            <div className="w-full flex items-center justify-between px-4 py-4 text-sm text-[#191F28] font-medium">
              푸시 알림
              <button onClick={() => setPushEnabled(v => !v)} className={`w-10 h-6 rounded-full flex items-center px-1 transition ${pushEnabled ? 'bg-[#FA2E55]' : 'bg-[#E5E8EB]' }`}>
                <span className={`w-4 h-4 rounded-full bg-white shadow transition-transform ${pushEnabled ? 'translate-x-4' : ''}`}></span>
              </button>
            </div>
            <button className="w-full flex items-center justify-between px-4 py-4 text-sm text-[#191F28] font-medium" onClick={onRoomManage}>
              방 관리
              <span className="material-icons text-base text-[#8B95A1]">chevron_right</span>
            </button>
            <button className="w-full flex items-center justify-between px-4 py-4 text-sm text-[#191F28] font-medium" onClick={onNotice}>
              공지사항
              <span className="material-icons text-base text-[#8B95A1]">chevron_right</span>
            </button>
            <button className="w-full flex items-center justify-between px-4 py-4 text-sm font-bold text-[#FA2E55]" onClick={() => setShowLogoutModal(true)}>
              로그아웃
            </button>
          </div>
        </div>
        {/* 로그아웃 모달 */}
        {showLogoutModal && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/20 z-20">
            <div className="bg-white rounded-2xl p-6 w-80 max-w-[90vw] flex flex-col items-center shadow-xl">
              <span className="material-icons text-4xl text-[#FA2E55] mb-2">warning_amber</span>
              <div className="text-lg font-bold text-[#FA2E55] mb-1">로그아웃</div>
              <div className="text-sm text-[#191F28] mb-6">정말 로그아웃 하시겠습니까?</div>
              <div className="flex gap-3 w-full">
                <button className="flex-1 h-10 rounded-xl border border-[#E5E8EB] bg-white text-[#191F28] text-sm font-bold" onClick={() => setShowLogoutModal(false)}>취소</button>
                <button className="flex-1 h-10 rounded-xl bg-[#FA2E55] text-white text-sm font-bold" onClick={() => { setShowLogoutModal(false); /* 실제 로그아웃 처리 */ }}>확인</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
} 