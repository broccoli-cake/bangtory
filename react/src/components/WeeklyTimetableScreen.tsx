import React from 'react';
import ReservationIcon from './ReservationIcon';
import type { ReservationType } from './ReservationIcon';

// MainScreen에서 사용한 ScreenType 타입 정의 복사
type ScreenType = 'onboarding' | 'roomSelect' | 'roomCreate' | 'loading' | 'main' | 'timetable' | 'calendar' | 'chat' | 'settings';

interface WeeklyTimetableScreenProps {
  onBack: () => void;
  setCurrentScreen?: (screen: ScreenType) => void;
}

const days = ['월', '화', '수', '목', '금', '토', '일'];
const times = Array.from({ length: 24 }, (_, i) => i); // 0~23

interface Reservation {
  type: ReservationType;
  day: number;
  start: number;
  end: number;
  name: string;
}

// 예시 예약 데이터
const reservations: Reservation[] = [
  { type: 'bath', day: 0, start: 1, end: 3, name: '김민영' },
  { type: 'laundry', day: 0, start: 2, end: 4, name: '홍수한' },
  { type: 'bath', day: 4, start: 5, end: 6, name: '민수연' },
];

const typeColor: { [key in ReservationType]: string } = {
  bath: '#FA2E55',
  laundry: '#FFBABA',
  visitor: '#8B95A1',
  add: '#D1D6DB',
};

export default function WeeklyTimetableScreen({ onBack, setCurrentScreen }: WeeklyTimetableScreenProps) {
  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="max-w-[390px] min-h-[844px] h-[844px] w-full bg-white shadow-2xl rounded-[24px] flex flex-col overflow-hidden relative">
        {/* 상단 헤더 */}
        <div className="flex items-center justify-between px-4 pt-6 pb-2 bg-white z-10">
          <button onClick={onBack} className="text-[#191F28] text-2xl px-2" aria-label="뒤로가기">←</button>
          <div className="flex-1 text-center text-lg font-bold text-[#191F28]">주간 시간표</div>
          <div className="w-8" />
        </div>
        {/* 주차 네비 */}
        <div className="flex items-center justify-center gap-4 px-4 mb-2">
          <button className="w-8 h-8 flex items-center justify-center text-[#8B95A1] text-xl">◀</button>
          <div className="flex flex-col items-center">
            <span className="text-base font-bold text-[#191F28]">5월 둘째주</span>
            <span className="text-xs text-[#8B95A1]">2025</span>
          </div>
          <button className="w-8 h-8 flex items-center justify-center text-[#8B95A1] text-xl">▶</button>
        </div>
        {/* 시간표 스크롤 */}
        <div className="flex-1 overflow-y-auto px-4 pb-2">
          <div className="relative bg-[#F9FAFB] rounded-xl p-2 border border-[#F2F4F6] mb-2 overflow-x-hidden">
            <div className="grid grid-cols-8 gap-0 w-full">
              <div className="sticky top-0 left-0 bg-[#F9FAFB] z-10" />
              {days.map((d, i) => (
                <div key={i} className="sticky top-0 bg-[#F9FAFB] z-10 text-xs text-[#8B95A1] font-bold text-center py-1">{d}</div>
              ))}
              {times.map((t) => (
                <React.Fragment key={t}>
                  <div className="text-xs text-[#8B95A1] font-bold text-center py-1 w-8">{t}</div>
                  {days.map((_, d) => {
                    // 해당 시간, 요일에 예약이 있는지 확인
                    const r = reservations.find(r => r.day === d && t >= r.start && t < r.end);
                    if (!r) {
                      return <div key={d} className="h-7 flex items-center justify-center border border-[#E5E8EB] bg-white" />;
                    }
                    // 예약 셀 스타일
                    return (
                      <div key={d} className="h-7 flex items-center justify-center border border-[#E5E8EB] bg-white">
                        <span
                          className="flex items-center gap-1 px-2 py-1 rounded-full text-xs font-bold"
                          style={{
                            color: typeColor[r.type],
                            border: `1.5px solid ${typeColor[r.type]}`,
                            background: `${typeColor[r.type]}22`,
                          }}
                        >
                          <ReservationIcon type={r.type as ReservationType} className="w-4 h-4" />
                          {r.name}
                        </span>
                      </div>
                    );
                  })}
                </React.Fragment>
              ))}
            </div>
          </div>
          {/* legend */}
          <div className="flex items-center gap-4 mt-2 px-2">
            <div className="flex items-center gap-1">
              <span className="w-3 h-3 rounded-full" style={{ background: typeColor.bath }} />
              <span className="text-xs text-[#8B95A1]">욕실</span>
            </div>
            <div className="flex items-center gap-1">
              <span className="w-3 h-3 rounded-full" style={{ background: typeColor.laundry }} />
              <span className="text-xs text-[#8B95A1]">세탁기</span>
            </div>
          </div>
        </div>
        {/* 하단 네비게이션 */}
        <nav className="absolute bottom-0 left-0 w-full bg-white border-t border-[#E5E8EB] flex justify-between items-center px-6 py-2 z-10 rounded-b-[24px]">
          <button className="flex flex-col items-center text-[#8B95A1] text-xs font-medium" onClick={() => setCurrentScreen && setCurrentScreen('calendar')}>
            <span className="material-icons text-[22px] mb-1">calendar_month</span>
            캘린더
          </button>
          <button className="flex flex-col items-center text-[#fa2e55] text-xs font-bold" onClick={() => setCurrentScreen && setCurrentScreen('timetable')}>
            <span className="material-icons text-[22px] mb-1">schedule</span>
            시간표
          </button>
          <button className="flex flex-col items-center text-[#8B95A1] text-xs font-medium" onClick={() => setCurrentScreen && setCurrentScreen('main')}>
            <span className="material-icons text-[22px] mb-1">home</span>
            홈
          </button>
          <button className="flex flex-col items-center text-[#8B95A1] text-xs font-medium" onClick={() => setCurrentScreen && setCurrentScreen('chat')}>
            <span className="material-icons text-[22px] mb-1">chat_bubble</span>
            채팅
          </button>
          <button className="flex flex-col items-center text-[#8B95A1] text-xs font-medium" onClick={() => setCurrentScreen && setCurrentScreen('settings')}>
            <span className="material-icons text-[22px] mb-1">settings</span>
            설정
          </button>
        </nav>
      </div>
    </div>
  );
} 