const express = require('express');
const { DoctorVisitPresenter } = require('../presenters');

const router = express.Router();

// Doctor visit routes
router.post('/users/:userId/doctor-visits', DoctorVisitPresenter.createDoctorVisitSummary.bind(DoctorVisitPresenter));
router.get('/users/:userId/doctor-visits', DoctorVisitPresenter.getDoctorVisitSummaries.bind(DoctorVisitPresenter));
router.get('/users/:userId/doctor-visits/:summaryId', DoctorVisitPresenter.getDoctorVisitSummaryById.bind(DoctorVisitPresenter));
router.put('/users/:userId/doctor-visits/:summaryId', DoctorVisitPresenter.updateDoctorVisitSummary.bind(DoctorVisitPresenter));
router.post('/users/:userId/doctor-visits/generate', DoctorVisitPresenter.generateDoctorVisitSummary.bind(DoctorVisitPresenter));
router.post('/users/:userId/doctor-visits/:summaryId/questions', DoctorVisitPresenter.addQuestionToSummary.bind(DoctorVisitPresenter));
router.post('/users/:userId/doctor-visits/:summaryId/share', DoctorVisitPresenter.shareSummary.bind(DoctorVisitPresenter));

module.exports = router;
