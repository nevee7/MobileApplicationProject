using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace AnimalFostering.API.Migrations
{
    /// <inheritdoc />
    public partial class AddAdoptionApplications : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "Shelters",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "GooglePlaceId",
                table: "Shelters",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsOpenNow",
                table: "Shelters",
                type: "boolean",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "OpeningHours",
                table: "Shelters",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<double>(
                name: "Rating",
                table: "Shelters",
                type: "double precision",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Source",
                table: "Shelters",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "Shelters",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "Website",
                table: "Shelters",
                type: "text",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "AdoptionApplications",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    AnimalId = table.Column<int>(type: "integer", nullable: false),
                    Status = table.Column<string>(type: "text", nullable: false),
                    Message = table.Column<string>(type: "text", nullable: true),
                    AdminNotes = table.Column<string>(type: "text", nullable: true),
                    ApplicationDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ReviewedDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    ReviewedByAdminId = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AdoptionApplications", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AdoptionApplications_Animals_AnimalId",
                        column: x => x.AnimalId,
                        principalTable: "Animals",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AdoptionApplications_Users_ReviewedByAdminId",
                        column: x => x.ReviewedByAdminId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AdoptionApplications_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ChatMessages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    SenderId = table.Column<int>(type: "integer", nullable: false),
                    ReceiverId = table.Column<int>(type: "integer", nullable: true),
                    MessageType = table.Column<string>(type: "text", nullable: false),
                    Content = table.Column<string>(type: "text", nullable: false),
                    IsRead = table.Column<bool>(type: "boolean", nullable: false),
                    SentAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChatMessages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ChatMessages_Users_ReceiverId",
                        column: x => x.ReceiverId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ChatMessages_Users_SenderId",
                        column: x => x.SenderId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PasswordResets",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Email = table.Column<string>(type: "text", nullable: false),
                    Token = table.Column<string>(type: "text", nullable: false),
                    ResetCode = table.Column<string>(type: "text", nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IsUsed = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PasswordResets", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AdoptionApplications_AnimalId",
                table: "AdoptionApplications",
                column: "AnimalId");

            migrationBuilder.CreateIndex(
                name: "IX_AdoptionApplications_ReviewedByAdminId",
                table: "AdoptionApplications",
                column: "ReviewedByAdminId");

            migrationBuilder.CreateIndex(
                name: "IX_AdoptionApplications_UserId",
                table: "AdoptionApplications",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatMessages_ReceiverId",
                table: "ChatMessages",
                column: "ReceiverId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatMessages_SenderId",
                table: "ChatMessages",
                column: "SenderId");

            migrationBuilder.CreateIndex(
                name: "IX_PasswordResets_Email",
                table: "PasswordResets",
                column: "Email");

            migrationBuilder.CreateIndex(
                name: "IX_PasswordResets_Token",
                table: "PasswordResets",
                column: "Token");

            migrationBuilder.CreateIndex(
                name: "IX_PasswordResets_Token_ResetCode_IsUsed",
                table: "PasswordResets",
                columns: new[] { "Token", "ResetCode", "IsUsed" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AdoptionApplications");

            migrationBuilder.DropTable(
                name: "ChatMessages");

            migrationBuilder.DropTable(
                name: "PasswordResets");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "Shelters");

            migrationBuilder.DropColumn(
                name: "GooglePlaceId",
                table: "Shelters");

            migrationBuilder.DropColumn(
                name: "IsOpenNow",
                table: "Shelters");

            migrationBuilder.DropColumn(
                name: "OpeningHours",
                table: "Shelters");

            migrationBuilder.DropColumn(
                name: "Rating",
                table: "Shelters");

            migrationBuilder.DropColumn(
                name: "Source",
                table: "Shelters");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "Shelters");

            migrationBuilder.DropColumn(
                name: "Website",
                table: "Shelters");
        }
    }
}
