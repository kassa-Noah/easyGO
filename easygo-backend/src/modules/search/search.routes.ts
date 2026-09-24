import { Router } from "express";
import { searchAvailableTrips } from "./search.controller";

const router = Router();

router.get("/trips", searchAvailableTrips);

export default router;