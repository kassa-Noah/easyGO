import { Request, Response } from "express";
import { searchTripsSchema } from "./search.schema";
import { searchTrips } from "./search.service";

export const searchAvailableTrips = async (
  req: Request,
  res: Response
) => {
  try {
    const validatedData = searchTripsSchema.parse(req.query);

    if (
      validatedData.originCity.toLowerCase() ===
      validatedData.destinationCity.toLowerCase()
    ) {
      return res.status(400).json({
        success: false,
        message: "Origin and destination cities must be different",
      });
    }

    const trips = await searchTrips(validatedData);

    return res.status(200).json({
      success: true,
      message:
        trips.length > 0
          ? "Available trips found"
          : "No available trips found",
      count: trips.length,
      data: trips,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message: error.message || "Trip search failed",
    });
  }
};