import React from 'react';

interface BathReservationScreenProps {
  onBack: () => void;
}

const days = ['월', '화', '수', '목', '금', '토', '일'];
const times = Array.from({ length: 24 }, (_, i) => i); // 0~23
const reservations = [
  { day: 0, time: 1, name: '김민영' },
  { day: 3, time: 4, name: '홍수한' },
  { day: 5, time: 3, name: '민수연' },
];

export default function BathReservationScreen({ onBack }: BathReservationScreenProps) {
  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="max-w-[390px] min-h-[844px] h-[844px] w-full bg-white shadow-2xl rounded-[24px] flex flex-col overflow-hidden">
        {/* 상단 헤더 */}
        <div className="flex items-center justify-between px-4 pt-6 pb-2 bg-white z-10">
          <button onClick={onBack} className="text-[#191F28] text-2xl px-2" aria-label="뒤로가기">←</button>
          <div className="flex-1 text-center text-lg font-bold text-[#191F28]">욕실 예약</div>
          <div className="w-8" />
        </div>
        {/* 예약표 + 폼 스크롤 */}
        <div className="flex-1 overflow-y-auto px-4 pb-6">
          {/* 타임테이블 */}
          <div className="relative bg-[#F9FAFB] rounded-xl p-4 border border-[#F2F4F6] mb-4 overflow-x-hidden">
            <div className="grid grid-cols-8 gap-0 w-full">
              <div className="sticky top-0 left-0 bg-[#F9FAFB] z-10" />
              {days.map((d, i) => (
                <div key={i} className="sticky top-0 bg-[#F9FAFB] z-10 text-xs text-[#8B95A1] font-bold text-center py-1">{d}</div>
              ))}
              {times.map((t) => (
                <React.Fragment key={t}>
                  <div className="text-xs text-[#8B95A1] font-bold text-center py-1 w-8">{t}</div>
                  {days.map((_, d) => {
                    const r = reservations.find(r => r.day === d && r.time === t);
                    return (
                      <div key={d} className={`h-8 flex items-center justify-center border border-[#F2F4F6] bg-white ${r ? 'border-[#FA2E55] bg-[#FFF0F4]' : ''}`}>
                        {r && (
                          <span className="text-xs text-[#FA2E55] font-bold px-2 py-1 rounded-full border border-[#FA2E55] bg-white whitespace-pre leading-tight">
                            {r.name.length > 2 ? `${r.name.slice(0,2)}\n${r.name.slice(2)}` : r.name}
                          </span>
                        )}
                      </div>
                    );
                  })}
                </React.Fragment>
              ))}
            </div>
          </div>
          {/* 새 일정 등록 */}
          <div className="bg-[#F9FAFB] rounded-xl p-4 border border-[#F2F4F6]">
            <div className="text-sm font-bold text-[#191F28] mb-3">새 일정 등록</div>
            <div className="mb-3">
              <div className="text-xs text-[#8B95A1] mb-1">요일 선택</div>
              <button className="w-full h-10 rounded-lg border border-[#E5E8EB] bg-white px-3 text-sm text-[#191F28] text-left">월요일</button>
            </div>
            <div className="mb-3 flex gap-2">
              <div className="flex-1">
                <div className="text-xs text-[#8B95A1] mb-1">시간 선택</div>
                <button className="w-full h-10 rounded-lg border border-[#E5E8EB] bg-white px-3 text-sm text-[#191F28] text-left">-- : --</button>
              </div>
              <div className="flex-1">
                <div className="text-xs text-[#8B95A1] mb-1">~</div>
                <button className="w-full h-10 rounded-lg border border-[#E5E8EB] bg-white px-3 text-sm text-[#191F28] text-left">-- : --</button>
              </div>
            </div>
            <div className="mb-4">
              <div className="text-xs text-[#8B95A1] mb-1">반복 선택</div>
              <div className="flex gap-2">
                <button className="flex-1 h-10 rounded-lg border border-[#E5E8EB] bg-white text-[#191F28] text-sm">없음</button>
                <button className="flex-1 h-10 rounded-lg border border-[#E5E8EB] bg-white text-[#191F28] text-sm">매주 반복</button>
              </div>
            </div>
            <button className="w-full h-11 bg-[#FA2E55] text-white rounded-xl text-[16px] font-bold flex items-center justify-center gap-2 mt-2 active:scale-95 transition">등록하기</button>
          </div>
        </div>
      </div>
    </div>
  );
} 