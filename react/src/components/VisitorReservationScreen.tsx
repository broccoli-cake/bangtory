import React from 'react';

interface VisitorReservationScreenProps {
  onBack: () => void;
}

const schedules = [
  { date: '2025.05.01. 목', name: '김민영', count: '2/4', time: '15:00~18:00', done: true },
  { date: '2025.05.02. 금', name: '홍수한', count: '1/4', time: '17:00~18:00', done: false },
  { date: '2025.05.08. 목', name: '최현경', count: '0/4', time: '12:00~13:00', done: false },
];

export default function VisitorReservationScreen({ onBack }: VisitorReservationScreenProps) {
  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="max-w-[390px] min-h-[844px] w-full h-full bg-white shadow-2xl rounded-[24px] px-4 pt-6 pb-8 flex flex-col justify-start">
        {/* 상단 헤더 */}
        <div className="flex items-center justify-between mb-4">
          <button onClick={onBack} className="text-[#191F28] text-2xl px-2" aria-label="뒤로가기">←</button>
          <div className="flex-1 text-center text-lg font-bold text-[#191F28]">방문객 예약</div>
          <div className="w-8" />
        </div>
        {/* 방문객 일정 */}
        <div className="bg-[#F9FAFB] rounded-xl p-4 mb-4 border border-[#F2F4F6]">
          <div className="text-sm font-bold text-[#191F28] mb-3">방문객 일정</div>
          {schedules.map((s, i) => (
            <div key={i} className="flex items-center justify-between mb-3 last:mb-0">
              <div className="flex flex-col">
                <span className="text-[#191F28] text-sm font-bold">{s.date} {s.name}</span>
                <span className="text-[#8B95A1] text-xs">({s.count})</span>
              </div>
              <div className="flex flex-col items-end">
                <span className="text-[#191F28] text-sm font-medium mb-1">{s.time}</span>
                {s.done ? (
                  <button className="h-7 px-3 text-xs rounded-full bg-[#E5E8EB] text-[#8B95A1] font-bold flex items-center gap-1 shadow-none cursor-default">확인 완료</button>
                ) : (
                  <button className="h-7 px-3 text-xs rounded-full bg-[#FA2E55] text-white font-bold flex items-center gap-1 shadow-none hover:bg-[#e0264a] active:scale-95 transition">확인</button>
                )}
              </div>
            </div>
          ))}
        </div>
        {/* 새 일정 등록 */}
        <div className="bg-[#F9FAFB] rounded-xl p-4 border border-[#F2F4F6]">
          <div className="text-sm font-bold text-[#191F28] mb-3">새 일정 등록</div>
          <div className="mb-3">
            <div className="text-xs text-[#8B95A1] mb-1">날짜 선택</div>
            <input type="text" className="w-full h-10 rounded-lg border border-[#E5E8EB] bg-[#F2F4F6] px-3 text-sm text-[#191F28]" value="2025.05.01.목" readOnly />
          </div>
          <div className="mb-3">
            <div className="text-xs text-[#8B95A1] mb-1">시간 선택</div>
            <input type="text" className="w-full h-10 rounded-lg border border-[#E5E8EB] bg-[#F2F4F6] px-3 text-sm text-[#191F28]" value="12:00 ~ 13:00" readOnly />
          </div>
          <button className="w-full h-11 bg-[#FA2E55] text-white rounded-xl text-[16px] font-bold flex items-center justify-center gap-2 mt-2 active:scale-95 transition">등록하기</button>
        </div>
      </div>
    </div>
  );
} 