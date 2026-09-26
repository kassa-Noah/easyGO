import express from "express";
import cors from "cors";

import authRoutes from "./modules/auth/auth.routes";
import userRoutes from "./modules/user/user.routes";
import agencyRoutes from "./modules/agency/agency.routes";
import routeRoutes from "./modules/route/route.routes";
import tripRoutes from "./modules/trip/trip.routes";
import searchRoutes from "./modules/search/search.routes";
import journeyRoutes from "./modules/journey/journey.routes";
import taxiRoutes from "./modules/taxi/taxi.routes";
import bookingRoutes from "./modules/booking/booking.routes";
import paymentRoutes from "./modules/payment/payment.routes";
import ticketRoutes from "./modules/ticket/ticket.routes";
import luggageRoutes from "./modules/luggage/luggage.routes";
import parcelRoutes from "./modules/parcel/parcel.routes";
import notificationRoutes from "./modules/notification/notification.routes";
import conversationRoutes from "./modules/conversation/conversation.routes";
import reviewRoutes from "./modules/review/review.routes";
import adminRoutes from "./modules/admin/admin.routes";
import staffRoutes from "./modules/staff/staff.routes";

const app = express();

app.use(cors());
app.use(express.json());

app.get(
  "/",
  (_req, res) => {
    res.status(200).json({
      success: true,
      message:
        "easyGO API is running",
    });
  }
);

app.use(
  "/api/auth",
  authRoutes
);

app.use(
  "/api/users",
  userRoutes
);

app.use(
  "/api/agencies",
  agencyRoutes
);

app.use(
  "/api/routes",
  routeRoutes
);

app.use(
  "/api/trips",
  tripRoutes
);

app.use(
  "/api/search",
  searchRoutes
);

app.use(
  "/api/journeys",
  journeyRoutes
);

app.use(
  "/api/taxi",
  taxiRoutes
);

app.use(
  "/api/bookings",
  bookingRoutes
);

app.use(
  "/api/payments",
  paymentRoutes
);

app.use(
  "/api/tickets",
  ticketRoutes
);

app.use(
  "/api/luggage",
  luggageRoutes
);

app.use(
  "/api/parcels",
  parcelRoutes
);

app.use(
  "/api/notifications",
  notificationRoutes
);

app.use(
  "/api/conversations",
  conversationRoutes
);

app.use(
  "/api/reviews",
  reviewRoutes
);

app.use(
  "/api/admin",
  adminRoutes
);

app.use(
  "/api/staff",
  staffRoutes
);

export default app;