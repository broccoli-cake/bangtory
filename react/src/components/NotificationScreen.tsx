import React, { useState } from 'react';

const initialNotifications = [
  {
    id: 1,
    type: 'visitor',
    title: '새로운 방문객 예약이 등록되었습니다.',
    detail: '2025 . 05. 08. 목\n12:00 - 13:00\n최현경 - 2명',
    time: '방금',
    checked: false,
  },
  {
    id: 2,
    type: 'chore',
    title: '새로운 집안일이 등록되었습니다...',
    time: '5분전',
    checked: true,
  },
  {
    id: 3,
    type: 'reservation',
    title: '새로운 예약이 등록되었습니다...',
    time: '5일전',
    checked: true,
  },
  {
    id: 4,
    type: 'chore',
    title: '새로운 집안일이 등록되었습니다...',
    time: '6일전',
    checked: true,
  },
];

export default function NotificationScreen({ onBack }: { onBack?: () => void }) {
  const [notifications, setNotifications] = useState(initialNotifications);

  const handleCheck = (id: number) => {
    setNotifications(n => n.map(notif => notif.id === id ? { ...notif, checked: true } : notif));
  };

  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="max-w-[390px] min-h-[844px] h-[844px] w-full bg-white shadow-2xl rounded-[24px] flex flex-col overflow-hidden relative">
        {/* 상단 헤더 */}
        <div className="flex items-center justify-between px-4 pt-6 pb-2 bg-white z-10">
          <button onClick={onBack} className="text-[#191F28] text-2xl px-2" aria-label="뒤로가기">←</button>
          <div className="flex-1 text-center text-lg font-bold text-[#191F28]">알림</div>
          <div className="w-8" />
        </div>
        {/* 알림 리스트 */}
        <div className="flex-1 overflow-y-auto px-4 pb-4 space-y-3">
          {notifications.map(notif => (
            <div
              key={notif.id}
              className={`rounded-2xl bg-white shadow-sm border ${notif.checked ? 'border-[#F2F4F6]' : 'border-[#FA2E55]'} px-4 py-3 flex flex-col gap-2 ${notif.checked ? 'opacity-70' : 'opacity-100'} transition`}
              style={notif.checked ? {} : { boxShadow: '0 0 0 2px #FA2E5522' }}
            >
              <div className="flex justify-between items-center mb-1">
                <span className="text-sm text-[#191F28] font-bold">{notif.title}</span>
                <span className="text-xs text-[#8B95A1] font-bold">{notif.time}</span>
              </div>
              {notif.detail && (
                <div className="bg-[#F2F4F6] rounded-lg p-3 text-xs text-[#191F28] whitespace-pre-line flex items-center justify-between">
                  <span>{notif.detail}</span>
                  {!notif.checked && (
                    <button className="ml-4 px-4 py-1 rounded-full bg-[#FA2E55] text-white text-xs font-bold active:scale-95 transition" onClick={() => handleCheck(notif.id)}>
                      확인
                    </button>
                  )}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
} 