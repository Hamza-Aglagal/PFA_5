'use client';

import { motion } from 'framer-motion';
import { Slide } from '../../../lib/types';

interface QualitySlideProps {
  slide: Slide;
}

export default function QualitySlide({ slide }: QualitySlideProps) {
  const { title, checklist, kpis } = slide.content;

  return (
    <div className={`relative w-full h-full flex items-center justify-center p-16 ${slide.background || 'bg-white'}`}>
      <div className="max-w-6xl w-full">
        {/* Title */}
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6 }}
          className="text-center mb-12"
        >
          <h1 className="text-6xl font-bold bg-gradient-to-r from-teal-600 via-cyan-600 to-sky-600 bg-clip-text text-transparent">
            {title}
          </h1>
        </motion.div>

        <div className="grid grid-cols-2 gap-12">
          {/* Left Column - Checklist */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
          >
            <div className="bg-white rounded-3xl p-8 shadow-2xl border-2 border-teal-200 h-full">
              <div className="flex items-center gap-3 mb-8">
                <div className="w-12 h-12 bg-gradient-to-br from-teal-500 to-cyan-500 rounded-xl flex items-center justify-center shadow-lg">
                  <span className="text-2xl">✓</span>
                </div>
                <h2 className="text-3xl font-bold text-gray-800">Qualité</h2>
              </div>

              <div className="space-y-4">
                {checklist?.map((item, index) => (
                  <motion.div
                    key={index}
                    initial={{ opacity: 0, x: -30 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ duration: 0.4, delay: 0.4 + index * 0.1 }}
                    className="flex items-start gap-4 p-4 bg-gradient-to-r from-teal-50 to-cyan-50 rounded-xl hover:shadow-md transition-all"
                  >
                    <div className="flex-shrink-0 w-6 h-6 bg-gradient-to-br from-teal-500 to-cyan-500 rounded-full flex items-center justify-center mt-1">
                      <span className="text-white text-xs">✓</span>
                    </div>
                    <p className="text-gray-800 leading-relaxed flex-1">
                      {item}
                    </p>
                  </motion.div>
                ))}
              </div>
            </div>
          </motion.div>

          {/* Right Column - KPIs Table */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6, delay: 0.3 }}
          >
            <div className="bg-white rounded-3xl p-8 shadow-2xl border-2 border-sky-200 h-full">
              <div className="flex items-center gap-3 mb-8">
                <div className="w-12 h-12 bg-gradient-to-br from-sky-500 to-blue-500 rounded-xl flex items-center justify-center shadow-lg">
                  <span className="text-2xl">📊</span>
                </div>
                <h2 className="text-3xl font-bold text-gray-800">KPIs</h2>
              </div>

              <div className="overflow-hidden rounded-xl border-2 border-sky-200">
                <table className="w-full">
                  <thead>
                    <tr className="bg-gradient-to-r from-sky-500 to-blue-500">
                      {kpis?.headers.map((header, index) => (
                        <th
                          key={index}
                          className="px-6 py-4 text-left text-white font-bold text-lg"
                        >
                          {header}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {kpis?.rows.map((row, rowIndex) => (
                      <motion.tr
                        key={rowIndex}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.4, delay: 0.6 + rowIndex * 0.1 }}
                        className={`${
                          rowIndex % 2 === 0 ? 'bg-sky-50' : 'bg-white'
                        } hover:bg-sky-100 transition-colors`}
                      >
                        {row.map((cell, cellIndex) => (
                          <td
                            key={cellIndex}
                            className="px-6 py-4 text-gray-800 border-b border-sky-100"
                          >
                            {cellIndex === 0 ? (
                              <span className="font-semibold">{cell}</span>
                            ) : (
                              <span className="font-bold text-sky-600 text-lg">
                                {cell}
                              </span>
                            )}
                          </td>
                        ))}
                      </motion.tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </motion.div>
        </div>

        {/* Decorative Elements */}
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ duration: 0.8, delay: 1 }}
          className="absolute top-16 right-16 w-32 h-32 bg-gradient-to-br from-teal-200/30 to-cyan-200/30 rounded-full blur-3xl"
        ></motion.div>
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ duration: 0.8, delay: 1.2 }}
          className="absolute bottom-16 left-16 w-40 h-40 bg-gradient-to-br from-sky-200/30 to-blue-200/30 rounded-full blur-3xl"
        ></motion.div>
      </div>
    </div>
  );
}
