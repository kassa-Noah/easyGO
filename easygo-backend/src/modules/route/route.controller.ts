import { Request, Response } from "express";

import { messageOf } from "../../lib/error-message";

import {
  createRoute,
  findExistingRoute,
  getAllRoutes,
  getBranchById,
  getRouteById,
  updateRoute,
} from "./route.service";

import {
  createRouteSchema,
  updateRouteSchema,
} from "./route.schema";

export const listRoutes = async (
  _req: Request,
  res: Response
) => {
  try {
    const routes = await getAllRoutes();

    return res.status(200).json({
      success: true,
      data: routes,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message: messageOf(error) || "Unable to retrieve routes",
    });
  }
};

export const getRoute = async (
  req: Request,
  res: Response
) => {
  try {
    const routeId = String(req.params.id);

    const route = await getRouteById(routeId);

    if (!route) {
      return res.status(404).json({
        success: false,
        message: "Route not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: route,
    });
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      message: messageOf(error) || "Unable to retrieve route",
    });
  }
};

export const addRoute = async (
  req: Request,
  res: Response
) => {
  try {
    const validatedData = createRouteSchema.parse(req.body);

    if (
      validatedData.originBranchId ===
      validatedData.destinationBranchId
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Origin and destination branches cannot be the same",
      });
    }

    const originBranch = await getBranchById(
      validatedData.originBranchId
    );

    if (!originBranch) {
      return res.status(404).json({
        success: false,
        message: "Origin branch not found",
      });
    }

    const destinationBranch = await getBranchById(
      validatedData.destinationBranchId
    );

    if (!destinationBranch) {
      return res.status(404).json({
        success: false,
        message: "Destination branch not found",
      });
    }

    const existingRoute = await findExistingRoute(
      validatedData.originBranchId,
      validatedData.destinationBranchId
    );

    if (existingRoute) {
      return res.status(409).json({
        success: false,
        message: "This route already exists",
      });
    }

    const route = await createRoute(validatedData);

    return res.status(201).json({
      success: true,
      message: "Route created successfully",
      data: route,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message: messageOf(error) || "Unable to create route",
    });
  }
};

export const editRoute = async (
  req: Request,
  res: Response
) => {
  try {
    const routeId = String(req.params.id);

    const existingRoute = await getRouteById(routeId);

    if (!existingRoute) {
      return res.status(404).json({
        success: false,
        message: "Route not found",
      });
    }

    const validatedData = updateRouteSchema.parse(req.body);

    const originBranchId =
      validatedData.originBranchId ??
      existingRoute.originBranchId;

    const destinationBranchId =
      validatedData.destinationBranchId ??
      existingRoute.destinationBranchId;

    if (originBranchId === destinationBranchId) {
      return res.status(400).json({
        success: false,
        message:
          "Origin and destination branches cannot be the same",
      });
    }

    if (validatedData.originBranchId) {
      const origin = await getBranchById(
        validatedData.originBranchId
      );

      if (!origin) {
        return res.status(404).json({
          success: false,
          message: "Origin branch not found",
        });
      }
    }

    if (validatedData.destinationBranchId) {
      const destination = await getBranchById(
        validatedData.destinationBranchId
      );

      if (!destination) {
        return res.status(404).json({
          success: false,
          message: "Destination branch not found",
        });
      }
    }

    const route = await updateRoute(
      routeId,
      validatedData
    );

    return res.status(200).json({
      success: true,
      message: "Route updated successfully",
      data: route,
    });
  } catch (error: any) {
    return res.status(400).json({
      success: false,
      message: messageOf(error) || "Unable to update route",
    });
  }
};